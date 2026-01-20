/*
MIT License

Copyright (c) 2025 Giuseppe Sorrentino, Paolo Salvatore Galfano, Davide
Conficconi, Eleonora D'Arnese

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

#include <ap_axi_sdata.h>
#include <fstream>
#include <hls_stream.h>
#include <iostream>

/**
 * @def PLIO_128
 * @brief Convenience constant representing a 128-bit PLIO width.
 */
#define PLIO_128 128

/**
 * @def PLIO_32
 * @brief Convenience constant representing a 32-bit PLIO width.
 */
#define PLIO_32 32

/**
 * @def BITS(x)
 * @brief Returns the size of type/expression @p x in bits (i.e., sizeof(x)*8).
 */
#define BITS(x) (sizeof(x) * 8)

/**
 * @brief Helper that writes scalar values to a text file with a fixed number of
 *        columns per row.
 *
 * Values are separated by spaces. A newline is inserted every @c columns
 * values. The @c counter tracks how many scalar elements have been written.
 *
 * This is primarily used to dump PLIO-like streams to text files for debugging
 * and testbench purposes.
 */
struct output_file_formatted {
  std::ofstream file;   ///< Output file stream.
  long int counter = 0; ///< Number of scalar elements written so far.
  const int columns;    ///< Number of scalar values per line.

  /**
   * @brief Construct the formatter and open the destination file.
   * @param filename Path of the file to open for writing.
   * @param columns  Number of scalar values per line (must be >= 1).
   *
   * @throws std::exception if @p columns < 1 or if the file cannot be opened.
   */
  output_file_formatted(const std::string &filename, int columns)
      : columns(columns) {
    if (columns < 1) {
      std::cout << "Error: columns must be >= 1" << std::endl;
      throw std::exception();
    }
    try {
      file.open(filename);
    } catch (std::exception &e) {
      std::cout << "Error opening file " << filename << std::endl;
      throw e;
    }
  }

  /**
   * @brief Write one scalar element using the configured column formatting.
   * @tparam T Scalar type (must be streamable with operator<<).
   * @param value The value to write.
   *
   * The function prints "@p value " and inserts a newline after @c columns
   * elements.
   */
  template <typename T> void write_aie_stream(T value) {
    file << value << " ";
    if (counter % columns == (columns - 1))
      file << std::endl;
    counter++;
  }

  /**
   * @brief Close the file on destruction.
   */
  ~output_file_formatted() { file.close(); }
};

/**
 * @brief Unpack a wide stream element into multiple narrower elements.
 *
 * Reads each @p TypeIn word from @p in and splits it into
 * N = BITS(TypeIn) / BITS(TypeOut) chunks. Each chunk is extracted with
 * bit-range slicing and written to @p out.
 *
 * @tparam TypeIn  Wide input type (e.g., ap_int<128>).
 * @tparam TypeOut Narrow output type (e.g., ap_int<32>, or a 32-bit scalar).
 * @param in  Input stream (drained until empty).
 * @param out Output stream receiving the unpacked elements.
 *
 * @note This function drains the input stream until it becomes empty.
 */
template <typename TypeIn, typename TypeOut>
void unpack(hls::stream<TypeIn> &in, hls::stream<TypeOut> &out) {
  static_assert(
      BITS(TypeIn) > BITS(TypeOut),
      "TypeIn must be larger than TypeOut (use pack instead of unpack)");
  static_assert(BITS(TypeIn) % BITS(TypeOut) == 0,
                "TypeIn must be a multiple of TypeOut");

  const int num_elems = BITS(TypeIn) / BITS(TypeOut);
  const int step = BITS(TypeOut);
  std::cout << "# Unpacking stream of " << BITS(TypeIn) << " bits into "
            << num_elems << " elements of " << step << " bits" << std::endl;

  while (!in.empty()) {
    const TypeIn data_in = in.read();
    for (int i = 0; i < num_elems; i++) {
      out.write(data_in.range((i + 1) * step - 1, i * step));
    }
  }
}

/**
 * @brief Pack multiple narrow stream elements into one wide element.
 *
 * Reads N = BITS(TypeOut) / BITS(TypeIn) consecutive elements of @p TypeIn
 * from @p in, packs them into a single @p TypeOut word using bit-range slicing,
 * and writes the result into @p out.
 *
 * @tparam TypeIn  Narrow input type (e.g., ap_int<32>).
 * @tparam TypeOut Wide output type (e.g., ap_int<128>).
 * @param in  Input stream (drained until empty).
 * @param out Output stream receiving the packed words.
 *
 * @warning This function assumes the total number of elements in @p in is a
 *          multiple of N. If not, it may attempt to read past available data
 *          (which would block in RTL simulation).
 */
template <typename TypeIn, typename TypeOut>
void pack(hls::stream<TypeIn> &in, hls::stream<TypeOut> &out) {
  static_assert(
      BITS(TypeIn) < BITS(TypeOut),
      "TypeIn must be smaller than TypeOut (use unpack instead of pack)");
  static_assert(BITS(TypeOut) % BITS(TypeIn) == 0,
                "TypeOut must be a multiple of TypeIn");

  const int num_elems = BITS(TypeOut) / BITS(TypeIn);
  const int step = BITS(TypeIn);
  std::cout << "# Packing stream of " << BITS(TypeIn) << " bits into "
            << num_elems << " elements of " << step << " bits" << std::endl;

  while (!in.empty()) {
    TypeOut data_out;
    for (int i = 0; i < num_elems; i++) {
      data_out.range((i + 1) * step - 1, i * step) = in.read();
    }
    out.write(data_out);
  }
}

/**
 * @brief Read scalar values from a whitespace-separated text file into an HLS
 *        stream.
 *
 * Parsing is performed using @c operator>> on the provided type @p T.
 * Reading stops at EOF or at the first non-parsable token for @p T.
 *
 * @tparam T Scalar type to read (must support @c operator>>).
 * @param stream_out Output HLS stream.
 * @param file_path  Input file path.
 * @return Number of elements pushed into @p stream_out.
 *
 * @throws std::exception if the file cannot be opened.
 */
template <typename T>
unsigned read_stream_from_file(hls::stream<T> &stream_out,
                               const std::string &file_path) {
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

  std::cout << "# Read " << stream_out.size() << " elements from file "
            << file_path << std::endl;

  return stream_out.size();
}

/**
 * @brief Read scalar values from a file and pack them into wide words.
 *
 * Reads @p TypeIn tokens from the input file into an intermediate stream, then
 * packs them into @p TypeOut words and pushes them to @p stream_out.
 *
 * @tparam TypeIn  Narrow type read from file.
 * @tparam TypeOut Wide type written to output stream.
 * @param stream_out Output stream of packed words.
 * @param file_path  Input file path.
 * @return Number of packed elements written to @p stream_out.
 *
 * @note The total number of read elements should be a multiple of
 *       BITS(TypeOut)/BITS(TypeIn) to avoid underflow during packing.
 */
template <typename TypeIn, typename TypeOut>
unsigned read_stream_from_file_pack(hls::stream<TypeOut> &stream_out,
                                    const std::string &file_path) {
  hls::stream<TypeIn> stream_out_unpacked("stream_out_unpacked");
  read_stream_from_file<TypeIn>(stream_out_unpacked, file_path);
  pack<TypeIn, TypeOut>(stream_out_unpacked, stream_out);
  return stream_out.size();
}

/**
 * @brief Read AXI4-Stream words (payload only) from a text file into an AXI HLS
 *        stream.
 *
 * The file is expected to contain whitespace-separated values matching the
 * payload field @c data.data. Side-band fields (e.g., TLAST/TKEEP/TUSER) are
 * not parsed and remain at default values.
 *
 * @tparam WData Data width in bits.
 * @tparam WUser USER width in bits.
 * @tparam WId   ID width in bits.
 * @tparam WDest DEST width in bits.
 * @param stream_out Output AXI stream.
 * @param file_path  Input file path.
 * @return Number of AXI words pushed into @p stream_out.
 *
 * @throws std::exception if the file cannot be opened.
 */
template <std::size_t WData, std::size_t WUser, std::size_t WId,
          std::size_t WDest>
unsigned read_stream_from_file(
    hls::stream<ap_axis<WData, WUser, WId, WDest>> &stream_out,
    const std::string &file_path) {
  std::ifstream file(file_path);
  if (!file.is_open()) {
    std::cout << "ERROR: could not open file " << file_path << std::endl;
    throw std::exception();
    return 0;
  }

  ap_axis<WData, WUser, WId, WDest> data;
  while (file >> data.data) {
    stream_out.write(data);
  }

  file.close();

  std::cout << "# Read " << stream_out.size() << " elements from file "
            << file_path << std::endl;

  return stream_out.size();
}

/**
 * @brief Dump an HLS scalar stream to a text file with PLIO-style formatting.
 *
 * The output is formatted in rows with:
 *   columns = plio_size_bits / BITS(T)
 * values per line. Values are separated by spaces.
 *
 * @tparam T Scalar stream element type.
 * @param stream_out Stream to dump (drained until empty).
 * @param file_path  Output file path.
 * @param plio_size  PLIO width in bits (e.g., PLIO_32, PLIO_128).
 *
 * @note This function drains the stream.
 */
template <typename T>
void write_stream_to_file(hls::stream<T> &stream_out,
                          const std::string &file_path, const int plio_size) {
  output_file_formatted file(file_path, plio_size / BITS(T));
  while (!stream_out.empty()) {
    file.write_aie_stream(stream_out.read());
  }

  std::cout << "# Wrote " << file.counter << " elements to file " << file_path
            << std::endl;
}

/**
 * @brief Unpack a wide stream, then dump the resulting scalar stream to file.
 *
 * This is a convenience wrapper around:
 *   1) unpack(TypeIn -> TypeOut)
 *   2) write_stream_to_file(TypeOut)
 *
 * @tparam TypeIn  Wide stream element type.
 * @tparam TypeOut Narrow stream element type written to file.
 * @param stream_out Input stream (drained).
 * @param file_path  Output file path.
 * @param plio_size  PLIO width in bits used to determine values per line.
 *
 * @note This function drains the input stream.
 */
template <typename TypeIn, typename TypeOut>
void write_stream_to_file_unpack(hls::stream<TypeIn> &stream_out,
                                 const std::string &file_path,
                                 const int plio_size) {
  hls::stream<TypeOut> stream_out_unpacked("stream_out_unpacked");
  unpack<TypeIn, TypeOut>(stream_out, stream_out_unpacked);
  write_stream_to_file<TypeOut>(stream_out_unpacked, file_path, plio_size);
}

/**
 * @brief Dump an AXI4-Stream (payload only) to a text file with PLIO-style
 * formatting.
 *
 * Only the @c .data field of each AXI word is written. Side-band fields are
 * ignored.
 *
 * @tparam WData Data width in bits.
 * @tparam WUser USER width in bits.
 * @tparam WId   ID width in bits.
 * @tparam WDest DEST width in bits.
 * @param stream_out AXI stream to dump (drained until empty).
 * @param file_path  Output file path.
 * @param plio_size  PLIO width in bits used to determine values per line.
 *
 * @note This function drains the stream.
 */
template <std::size_t WData, std::size_t WUser, std::size_t WId,
          std::size_t WDest>
void write_stream_to_file(
    hls::stream<ap_axis<WData, WUser, WId, WDest>> &stream_out,
    const std::string &file_path, const int plio_size) {
  output_file_formatted file(file_path, plio_size / WData);
  while (!stream_out.empty()) {
    file.write_aie_stream(stream_out.read().data);
  }

  std::cout << "# Wrote " << file.counter << " elements to file " << file_path
            << std::endl;
}

/**
 * @brief Assert the current size of an HLS stream matches an expected value.
 *
 * This is mainly intended for C simulation and testbenches. In RTL, stream
 * sizes may not be queryable the same way.
 *
 * @tparam T Stream element type.
 * @param stream        Stream to check.
 * @param expected_size Expected number of elements currently stored in the
 * stream.
 * @return True if sizes match.
 *
 * @throws std::exception if the size does not match.
 */
template <typename T>
bool assert_stream_size(hls::stream<T> &stream, const int expected_size) {
  if (stream.size() != expected_size) {
    std::cerr << "ERROR: stream size is " << stream.size() << " but expected "
              << expected_size << std::endl;
    throw std::exception();
    return false;
  }
  return true;
}

/**
 * @brief Read tokens from a text file into an HLS stream, skipping "TLAST".
 *
 * Some simulator-generated dumps may interleave textual markers (e.g., "TLAST")
 * among numeric tokens. This function parses the file token-by-token:
 *   - numeric tokens are converted to @p T and pushed to the stream
 *   - the literal token "TLAST" is ignored
 *
 * @tparam T        Stream element type (must support operator>> from istream).
 * @param out       Output HLS stream receiving numeric tokens.
 * @param file_path Input file path.
 * @return Number of numeric elements pushed to @p out.
 *
 * @throws std::exception if the file cannot be opened.
 *
 * @note This function does not stop at "TLAST"; it simply ignores it, because
 *       the marker may not appear as the last token in some logs.
 */
template <typename T>
unsigned read_stream_from_file_skip_tlast(hls::stream<T> &out,
                                          const std::string &file_path) {
  std::ifstream file(file_path);
  if (!file.is_open())
    throw std::exception();

  std::string tok;
  unsigned count = 0;
  while (file >> tok) {
    if (tok == "TLAST")
      continue;
    std::istringstream iss(tok);
    T value;
    if (iss >> value) {
      out.write(value);
      count++;
    }
  }
  return count;
}
