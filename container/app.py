from http.server import BaseHTTPRequestHandler, HTTPServer
import os


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        cloud_provider = os.getenv("CLOUD_PROVIDER", "unknown")
        assignment_week = os.getenv("ASSIGNMENT_WEEK", "6")
        body = (
            "<html><body>"
            f"<h1>Hello World from CAA week {assignment_week}</h1>"
            f"<p>This container is running on: {cloud_provider}</p>"
            "</body></html>"
        ).encode("utf-8")

        self.send_response(200)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)


if __name__ == "__main__":
    server = HTTPServer(("0.0.0.0", 8080), Handler)
    server.serve_forever()
