#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
# Directory to store downloaded models
MODELS_DIR="models"
# Directory containing the file to be unzipped
KNOWLEDGE_DIR="knowledge"
# URL of the model to download
MODEL_URL="https://huggingface.co/unsloth/Qwen3-0.6B-GGUF/resolve/main/Qwen3-0.6B-UD-Q4_K_XL.gguf"
# Desired name for the downloaded model file
MODEL_NAME="Qwen3-0.6B-UD-Q4_K_XL.gguf"

ARCHIVE_FILE_NAME="NGCI Encyclopedia Book of Abstracts.zip" # <-- REPLACE THIS!
# --- End Configuration ---

# Ensure target directories exist
echo "Ensuring '$MODELS_DIR' directory exists..."
mkdir -p "$MODELS_DIR"
echo "'$MODELS_DIR' directory is ready."
echo

if [ ! -d "$KNOWLEDGE_DIR" ]; then
    echo "Warning: '$KNOWLEDGE_DIR' directory does not exist. Please create it and place your archive file inside."
    # Optionally, create it:
    # echo "Creating '$KNOWLEDGE_DIR' directory..."
    # mkdir -p "$KNOWLEDGE_DIR"
fi
echo

# Download the model
MODEL_DEST_PATH="$MODELS_DIR/$MODEL_NAME"
echo "Downloading model '$MODEL_NAME' from '$MODEL_URL'..."
if [ -f "$MODEL_DEST_PATH" ]; then
    echo "Model '$MODEL_DEST_PATH' already exists. Skipping download."
else
    if curl -L -o "$MODEL_DEST_PATH" "$MODEL_URL"; then
        echo "Model downloaded successfully to '$MODEL_DEST_PATH'."
    else
        echo "Failed to download model. Please check the URL and your internet connection."
        # Clean up partially downloaded file if curl failed non-zero
        if [ -f "$MODEL_DEST_PATH" ]; then
            rm "$MODEL_DEST_PATH"
        fi
        exit 1
    fi
fi
echo

# Unzip the file in the knowledge directory
ARCHIVE_FULL_PATH="$KNOWLEDGE_DIR/$ARCHIVE_FILE_NAME"
echo "Preparing to process archive '$ARCHIVE_FULL_PATH'..."

if [ "$ARCHIVE_FILE_NAME" == "your_archive_file.zip" ]; then
    echo "Placeholder archive name '$ARCHIVE_FILE_NAME' is still set."
    echo "Please edit the script and set the ARCHIVE_FILE_NAME variable to your actual file name."
    exit 1
fi

if [ ! -f "$ARCHIVE_FULL_PATH" ]; then
    echo "Error: Archive file '$ARCHIVE_FULL_PATH' not found."
    echo "Please make sure the file exists in the '$KNOWLEDGE_DIR' directory and that"
    echo "the ARCHIVE_FILE_NAME variable is set correctly in this script."
    exit 1
fi

echo "Attempting to decompress '$ARCHIVE_FULL_PATH' into '$KNOWLEDGE_DIR'..."
# Determine the type of archive and unzip accordingly
if [[ "$ARCHIVE_FILE_NAME" == *.zip ]]; then
    if unzip -o "$ARCHIVE_FULL_PATH" -d "$KNOWLEDGE_DIR"; then
        echo "Successfully unzipped '$ARCHIVE_FULL_PATH' into '$KNOWLEDGE_DIR'."
    else
        echo "Failed to unzip '$ARCHIVE_FULL_PATH'."
        echo "Make sure 'unzip' is installed (sudo apt install unzip) and the file is a valid .zip archive."
        exit 1
    fi
elif [[ "$ARCHIVE_FILE_NAME" == *.tar.gz ]] || [[ "$ARCHIVE_FILE_NAME" == *.tgz ]]; then
    if tar -xzf "$ARCHIVE_FULL_PATH" -C "$KNOWLEDGE_DIR"; then
        echo "Successfully extracted '$ARCHIVE_FULL_PATH' into '$KNOWLEDGE_DIR'."
    else
        echo "Failed to extract '$ARCHIVE_FULL_PATH'."
        echo "Make sure 'tar' is installed and the file is a valid .tar.gz or .tgz archive."
        exit 1
    fi
elif [[ "$ARCHIVE_FILE_NAME" == *.gz ]]; then
    # For single .gz files, gunzip extracts and by default removes the .gz extension.
    # The -k option keeps the original file. Output is directed to KNOWLEDGE_DIR.
    OUTPUT_GZIP_NAME=$(basename "$ARCHIVE_FILE_NAME" .gz)
    if gunzip -k -c "$ARCHIVE_FULL_PATH" > "$KNOWLEDGE_DIR/$OUTPUT_GZIP_NAME"; then
        echo "Successfully gunzipped '$ARCHIVE_FULL_PATH' to '$KNOWLEDGE_DIR/$OUTPUT_GZIP_NAME'."
    else
        echo "Failed to gunzip '$ARCHIVE_FULL_PATH'."
        echo "Make sure 'gunzip' is installed and the file is a valid .gz archive."
        exit 1
    fi
elif [[ "$ARCHIVE_FILE_NAME" == *.tar ]]; then
    if tar -xf "$ARCHIVE_FULL_PATH" -C "$KNOWLEDGE_DIR"; then
        echo "Successfully extracted '$ARCHIVE_FULL_PATH' into '$KNOWLEDGE_DIR'."
    else
        echo "Failed to extract '$ARCHIVE_FULL_PATH'."
        echo "Make sure 'tar' is installed and the file is a valid .tar archive."
        exit 1
    fi
else
    echo "Error: Unsupported archive type for '$ARCHIVE_FILE_NAME'."
    echo "This script currently supports .zip, .tar.gz, .tgz, .gz, and .tar files."
    echo "Please modify the script to handle other types or use a supported format."
    exit 1
fi

echo
echo "Setup script completed."
