#!/usr/bin/env python3
import sys
import argparse
import jsonschema
import yaml
import json

def validate(schema_filepath, yaml_document_filepath):
    # load files
    with open(schema_filepath) as schema_file:
        schema = json.load(schema_file)

    with open(yaml_document_filepath) as yaml_document_file:
        data = yaml.safe_load(yaml_document_file)

    # validate
    try:
        jsonschema.validate(data, schema)
    except jsonschema.ValidationError as e:
        message = f"ERROR: Invalid setting file '{yaml_document_filepath}': " \
                + f"{e.message} in {'/'.join(str(node) for node in e.path)}.\n" \
                + f"---\n{e.instance}\n---"
        print(message, file=sys.stderr)
        exit(1)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-s", "--schema", help="JSON Schema to validate from")
    parser.add_argument("-y", "--yaml-document", help="YAML document to validate")
    args = parser.parse_args()

    validate(args.schema, args.yaml_document)

if __name__ == "__main__":
    main()
