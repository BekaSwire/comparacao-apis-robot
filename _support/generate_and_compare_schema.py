import json
import sys
from genson import SchemaBuilder
from deepdiff import DeepDiff
from jsonschema import validate, ValidationError

def load_json(file_path):
    """Carrega um JSON a partir de um arquivo."""
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            return json.load(f)
    except Exception as e:
        sys.stderr.write(json.dumps({"status": "fail", "message": f"❌ Error loading {file_path}: {e}"}))
        sys.exit(1)

def generate_schema(json_data):
    """Gera um JSON Schema automaticamente a partir dos dados."""
    builder = SchemaBuilder()
    builder.add_object(json_data)
    return builder.to_schema()

def save_schema(schema, filename):
    """Salva um JSON Schema em um arquivo."""
    with open(filename, "w", encoding="utf-8") as f:
        json.dump(schema, f, indent=4)
    sys.stderr.write(f"✅ Schema salvo em: {filename}\n")

def compare_schemas(old_schema, new_schema):
    """Compara dois schemas JSON e retorna as diferenças encontradas."""
    diff = DeepDiff(old_schema, new_schema, ignore_order=True, verbose_level=2)

    differences = {
        "added_keys": list(diff.get("dictionary_item_added", [])),   # Novas chaves no schema novo
        "removed_keys": list(diff.get("dictionary_item_removed", [])),  # Chaves que sumiram no schema novo
        "modified_types": [
            {
                "key": key,
                "old_type": str(diff["type_changes"][key]["old_type"]),
                "new_type": str(diff["type_changes"][key]["new_type"])
            }
            for key in diff.get("type_changes", {})
        ]
    }

    return differences

def compare_required_fields(old_schema, new_schema):
    """Compara os campos obrigatórios (required) entre os dois schemas."""

    old_required = set(old_schema.get("items", {}).get("required", []))
    new_required = set(new_schema.get("items", {}).get("required", []))

    removed_required = list(old_required - new_required)  # Campos que eram obrigatórios e deixaram de ser
    added_required = list(new_required - old_required)    # Campos que passaram a ser obrigatórios

    return {
        "removed_required": removed_required,
        "added_required": added_required
    }

if __name__ == "__main__":
    if len(sys.argv) < 3:
        sys.stderr.write(json.dumps({"status": "fail", "message": "❌ Missing JSON file paths"}))
        sys.exit(1)

    old_api_json = load_json(sys.argv[1])
    new_api_json = load_json(sys.argv[2])

    old_schema = generate_schema(old_api_json)
    new_schema = generate_schema(new_api_json)

    # Salvar schemas gerados
    old_schema_path = "../_fixtures/schema_old.json"
    new_schema_path = "../_fixtures/schema_new.json"
    
    save_schema(old_schema, old_schema_path)
    save_schema(new_schema, new_schema_path)

    # Comparar schemas
    differences = compare_schemas(old_schema, new_schema)
    required_differences = compare_required_fields(old_schema, new_schema)

    # Adicionar mudanças nos campos obrigatórios ao dicionário de diferenças
    differences["removed_required"] = required_differences["removed_required"]
    differences["added_required"] = required_differences["added_required"]

    # Determinar status com base nas diferenças
    status = "fail" if any(differences.values()) else "pass"

    # Contar número total de diferenças
    total_differences = sum(len(v) for v in differences.values() if isinstance(v, list))

    # Exibir resultados em JSON formatado
    print(json.dumps({
        "status": status,
        "message": "✅ API schemas compared successfully" if status == "pass" else "❌ Differences found in schema",
        "old_schema_path": old_schema_path,
        "new_schema_path": new_schema_path,
        "differences": differences,
        "total_differences": total_differences
    }, indent=4))
