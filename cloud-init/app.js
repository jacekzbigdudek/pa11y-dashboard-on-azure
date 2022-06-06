const http = require('http');

//This is the loopback IP address also referred to as localhost:
const hostname = '127.0.0.1';

// Default port for http traffic:
const port = 3000;

const server = http.createServer((req, res) => {
    res.statusCode = 200;
    res.setHeader('Content-Type', 'text/plain');
    res.end('Hello World');
});

server.listen(port, hostname, () => {
    console.log(`Server running at http://${hostname}:${port}/`);
});

