"""Servidor local para o jogo exportado. Uso: python serve.py [pasta] [porta]."""
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
import sys

class GameHandler(SimpleHTTPRequestHandler):
    extensions_map = {**SimpleHTTPRequestHandler.extensions_map, ".wasm": "application/wasm", ".pck": "application/octet-stream", ".js": "text/javascript"}
    def end_headers(self):
        self.send_header("Cache-Control", "no-store")
        super().end_headers()

if __name__ == "__main__":
    root = Path(sys.argv[1]).resolve() if len(sys.argv)>1 else Path(__file__).resolve().parent
    port = int(sys.argv[2]) if len(sys.argv)>2 else 8765
    if not (root/"index.html").is_file():
        raise SystemExit("Não encontrei index.html. Informe a pasta do jogo exportado.")
    server = ThreadingHTTPServer(("127.0.0.1",port),partial(GameHandler,directory=str(root)))
    print(f"Café com Patas: http://127.0.0.1:{port}/\nCtrl+C encerra o servidor.",flush=True)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()
