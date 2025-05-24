# Makefile

.PHONY: clean gen_kernel

# Files to keep (space-separated)
KEEP := gen_template.py kernel.cfg Makefile

# Default target
all: gen_kernel

# Generate kernel files by running the Python template script
gen_kernel:
	@echo "Generating kernel with gen_template.py"
	python3 gen_template.py

# Remove everything except the files in KEEP
clean:
	@echo "Cleaning up directory, preserving: $(KEEP)"
	@for file in *; do \
	  keep=false; \
	  for k in $(KEEP); do \
	    if [ "$$file" = "$$k" ]; then keep=true; fi; \
	  done; \
	  if [ $$keep = false ]; then \
	    echo "  Removing $$file"; \
	    rm -rf -- "$$file"; \
	  fi; \
	done
