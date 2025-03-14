import http.server
import socketserver
import os
import subprocess

PORT = 8080
MOCK_FILE = os.path.join(os.path.dirname(__file__), "../_fixtures/new_request_mock.txt")

def kill_existing_mock_server():
    """Verifica se há um processo rodando na porta 8080 e finaliza."""
    try:
        result = subprocess.run("netstat -ano | findstr :8080", shell=True, capture_output=True, text=True)
        lines = result.stdout.strip().split("\n")
        
        for line in lines:
            parts = line.split()
            if parts:  # Verifica se há dados na linha
                pid = parts[-1]  # O último valor é o PID
                subprocess.run(f"taskkill /PID {pid} /F", shell=True)
                print(f"🔴 Processo na porta 8080 finalizado (PID: {pid})")
    except Exception as e:
        print(f"Erro ao tentar finalizar o processo na porta 8080: {e}")

class MockRequestHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/v2/breeds":
            try:
                with open(MOCK_FILE, "r", encoding="utf-8") as file:
                    data = file.read()
                    self.send_response(200)
                    self.send_header("Content-type", "application/json")
                    self.end_headers()
                    self.wfile.write(data.encode("utf-8"))
            except FileNotFoundError:
                self.send_error(404, "Mock file not found")
        else:
            self.send_error(404, "Not Found")

# Inicia o servidor
def run_mock_server():
    """Inicia o servidor Mock após garantir que nenhum outro processo está rodando."""
    kill_existing_mock_server()  # Chama a função para matar o processo anterior
    with socketserver.TCPServer(("127.0.0.1", PORT), MockRequestHandler) as httpd:
        print(f"✅ Mock server running on http://127.0.0.1:{PORT}")
        httpd.serve_forever()

if __name__ == "__main__":
    run_mock_server()
