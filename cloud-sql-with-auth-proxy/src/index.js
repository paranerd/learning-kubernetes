const express = require('express');
const mysql = require('mysql2/promise');
const app = express();
const cors = require('cors')
const path = require('path');

const port = process.env.PORT || 8080;

app.use(cors());

// Get database connection
async function getConnection() {
  try {
    const connection = await mysql.createConnection({
        host: process.env.DB_HOST || 'localhost',
        user: process.env.DB_USER || 'root',
        password: process.env.DB_PASS || '',
        database: process.env.DB_NAME || 'demo',
      });

      console.log('Connected to the database');

    return connection;
  } catch (err) {
    console.error("Error getting connection from pool:", err);
    throw err; // Re-throw the error to be caught by the route handler
  }
}

// Route to serve the index.html file
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'index.html'));
});

// Route to serve data from database
app.get('/api/data', async (req, res) => {
    try {
        const connection = await getConnection();
        try {
            const [results, fields] = await connection.query(
            'SELECT * FROM `users`'
            );

            res.json(results);
        } catch (err) {
            console.log("Error executing query:", err);
            res.status(500).json({ error: "Error fetching data from the database" });
        }
    } catch (error) {
        res.status(500).json({ error: "Failed to connect to the database" });
    }
});

app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
