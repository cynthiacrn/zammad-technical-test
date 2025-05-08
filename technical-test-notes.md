# Technical Test Notes

## Environment Setup

During the technical test, I prepared a local development environment using Docker Compose. The setup included the following services:

- **PostgreSQL**: For relational database storage.
- **Redis**: As an in-memory data structure store.
- **Elasticsearch**: For search capabilities.

I also created a `.env` file to manage environment-specific variables cleanly.

## Development Files

Normally, I would exclude these development-related files from version control (e.g., via `.gitignore`). However, for the purpose of transparency and to showcase my working process during this technical test, I included and pushed the following files:

- `docker-compose.yml`
- `.env`

This decision was intentional to give reviewers a clear picture of how I structure and configure my development environment.
