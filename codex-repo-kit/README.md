# Codex Repository Kit

Generate a Codex-friendly, agentic coding repository based on the structure and assets of this project.

## Usage

```bash
./create-codex-repo.sh /path/to/new-repo
```

What the script does:

- Copies compatible assets from this repository into the target directory.
- Applies a light genericization pass for Claude-specific wording in Markdown and text files.
- Inserts Codex-oriented templates for `README.md` and `CONTRIBUTING.md`.
- Initializes a new Git repository on the `main` branch with an initial commit.

## Notes

- The script assumes a Linux environment and requires `git`, `rsync`, and `python3`.
- You can rerun the script to regenerate a repository by deleting the target directory first.
