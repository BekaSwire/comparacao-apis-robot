import json
import sys
from deepdiff import DeepDiff

def load_json(file_path):
    """Carrega um JSON a partir de um arquivo."""
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            return json.load(f)
    except Exception as e:
        sys.stderr.write(json.dumps({"status": "fail", "message": f"❌ Error loading {file_path}: {e}"}))
        sys.exit(1)

def compare_content(old_json, new_json):
    """Compara o conteúdo dos dois JSONs e retorna as diferenças."""
    diff = DeepDiff(old_json, new_json, ignore_order=True, verbose_level=2)

    differences = {
        "added_values": diff.get("values_changed", {}),
        "removed_values": diff.get("dictionary_item_removed", {}),
        "added_keys": diff.get("dictionary_item_added", {})
    }

    total_differences = sum(len(v) for v in differences.values())

    return differences, total_differences

if __name__ == "__main__":
    if len(sys.argv) < 3:
        sys.stderr.write(json.dumps({"status": "fail", "message": "❌ Missing JSON file paths"}))
        sys.exit(1)

    old_api_json = load_json(sys.argv[1])
    new_api_json = load_json(sys.argv[2])

    differences, total_differences = compare_content(old_api_json, new_api_json)

    status = "fail" if total_differences > 0 else "pass"

    print(json.dumps({
        "status": status,
        "message": "✅ API content compared successfully",
        "old_json_path": sys.argv[1],
        "new_json_path": sys.argv[2],
        "differences": differences,
        "total_differences": total_differences
    }, indent=4))
