/*
MIT License

Copyright (c) 2025 Giuseppe Sorrentino, Paolo Salvatore Galfano, Davide Conficconi, Eleonora D'Arnese

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

#include <iostream>
#include <fstream>
#include <hls_stream.h>
#include <ap_axi_sdata.h>

#define PLIO_128 128
#define PLIO_32 32
#define BITS(x) (sizeof(x) * 8)
struct output_file_formatted {
    std::ofstream file;
    long int counter = 0;
    const int columns;

    output_file_formatted(const std::string& filename, int columns) : columns(columns) {
        if (columns < 1) {
            std::cout << "Error: columns must be >= 1" << std::endl;
            throw std::exception();
        }
        try {
            file.open(filename);
        } catch (std::exception& e) {
            std::cout << "Error opening file " << filename << std::endl;
            throw e;
        }
    }

    template <typename T>
    void write_aie_stream(T value) {
        file << value << " ";
        if (counter % columns == (columns - 1))
            file << std::endl;
        counter++;
    }

    ~output_file_formatted() {
        file.close();
    }
};

template <typename TypeIn, typename TypeOut>
void unpack(hls::stream<TypeIn>& in, hls::stream<TypeOut>& out) {
    static_assert(BITS(TypeIn) > BITS(TypeOut), "TypeIn must be larger than TypeOut (use pack instead of unpack)");
    static_assert(BITS(TypeIn) % BITS(TypeOut) == 0, "TypeIn must be a multiple of TypeOut");

    const int num_elems = BITS(TypeIn) / BITS(TypeOut);
    const int step = BITS(TypeOut);
    std::cout << "# Unpacking stream of " << BITS(TypeIn) << " bits into " << num_elems << " elements of " << step << " bits" << std::endl;

    while (!in.empty()) {
        const TypeIn data_in = in.read();
        for (int i = 0; i < num_elems; i++) {
            out.write(data_in.range((i + 1) * step - 1, i * step));
        }
    }
}

template <typename TypeIn, typename TypeOut>
void pack(hls::stream<TypeIn>& in, hls::stream<TypeOut>& out) {
    static_assert(BITS(TypeIn) < BITS(TypeOut), "TypeIn must be smaller than TypeOut (use unpack instead of pack)");
    static_assert(BITS(TypeOut) % BITS(TypeIn) == 0, "TypeOut must be a multiple of TypeIn");

    const int num_elems = BITS(TypeOut) / BITS(TypeIn);
    const int step = BITS(TypeIn);
    std::cout << "# Packing stream of " << BITS(TypeIn) << " bits into " << num_elems << " elements of " << step << " bits" << std::endl;

    while (!in.empty()) {
        TypeOut data_out;
        for (int i = 0; i < num_elems; i++) {
            data_out.range((i + 1) * step - 1, i * step) = in.read();
        }
        out.write(data_out);
    }
}

template <typename T>
unsigned read_stream_from_file(hls::stream<T>& stream_out, const std::string& file_path) {
    std::ifstream file(file_path);
    if (!file.is_open()) {
        std::cout << "ERROR: could not open file " << file_path << std::endl;
        throw std::exception();
        return 0;
    }

    T data;
    while (file >> data) {
        stream_out.write(data);
    }

    file.close();

    std::cout << "# Read " << stream_out.size() << " elements from file " << file_path << std::endl;

    return stream_out.size();
}

template <typename TypeIn, typename TypeOut>
unsigned read_stream_from_file_pack(hls::stream<TypeOut>& stream_out, const std::string& file_path) {
    hls::stream<TypeIn> stream_out_unpacked("stream_out_unpacked");
    read_stream_from_file<TypeIn>(stream_out_unpacked, file_path);
    pack<TypeIn, TypeOut>(stream_out_unpacked, stream_out);
    return stream_out.size();
}

template <std::size_t WData, std::size_t WUser, std::size_t WId, std::size_t WDest>
unsigned read_stream_from_file(hls::stream<ap_axis<WData,WUser,WId,WDest>>& stream_out, const std::string& file_path) {
    std::ifstream file(file_path);
    if (!file.is_open()) {
        std::cout << "ERROR: could not open file " << file_path << std::endl;
        throw std::exception();
        return 0;
    }

    ap_axis<WData,WUser,WId,WDest> data;
    while (file >> data.data) {
        stream_out.write(data);
    }

    file.close();

    std::cout << "# Read " << stream_out.size() << " elements from file " << file_path << std::endl;

    return stream_out.size();
}

template <typename T>
void write_stream_to_file(hls::stream<T>& stream_out, const std::string& file_path, const int plio_size) {
    output_file_formatted file(file_path, plio_size / BITS(T));
    while (!stream_out.empty()) {
        file.write_aie_stream(stream_out.read());
    }

    std::cout << "# Wrote " << file.counter << " elements to file " << file_path << std::endl;
}

template <typename TypeIn, typename TypeOut>
void write_stream_to_file_unpack(hls::stream<TypeIn>& stream_out, const std::string& file_path, const int plio_size) {
    hls::stream<TypeOut> stream_out_unpacked("stream_out_unpacked");
    unpack<TypeIn, TypeOut>(stream_out, stream_out_unpacked);
    write_stream_to_file<TypeOut>(stream_out_unpacked, file_path, plio_size);
}

template <std::size_t WData, std::size_t WUser, std::size_t WId, std::size_t WDest>
void write_stream_to_file(hls::stream<ap_axis<WData,WUser,WId,WDest>>& stream_out, const std::string& file_path, const int plio_size) {
    output_file_formatted file(file_path, plio_size / WData);
    while (!stream_out.empty()) {
        file.write_aie_stream(stream_out.read().data);
    }

    std::cout << "# Wrote " << file.counter << " elements to file " << file_path << std::endl;
}

template <typename T>
bool assert_stream_size(hls::stream<T>& stream, const int expected_size) {
    if (stream.size() != expected_size) {
        std::cerr << "ERROR: stream size is " << stream.size() << " but expected " << expected_size << std::endl;
        throw std::exception();
        return false;
    }
    return true;
}
