# PowerShell + DevOps Global Summit — Session Materials

Welcome to the official repository for speaker session materials for the **PowerShell + DevOps Global Summit**. This repo is the central hub for slide decks, code samples, demos, and any other resources shared by our speakers.

---

## 📅 Event Details

- **Event:** PowerShell + DevOps Global Summit 2026
- **Website:** *https://powershellsummit.org*
- **Dates:** *April 13-17, 2026*
- **Location:** *Bellevue WA*

---

## 📁 Repository Structure

Materials are organized by speaker session. Each session lives in its own folder under the root of the repo:

```
/
├── SessionTitle-SpeakerLastName/
│   ├── slides/
│   ├── demo/
│   └── README.md        ← optional, but encouraged
├── AnotherSession-SpeakerLastName/
│   └── ...
```

---

## 📝 File & Folder Naming Conventions

To keep things consistent and searchable, please follow these conventions:

| Item | Convention | Example |
|---|---|---|
| Session folder | `SessionTitle-SpeakerLastName` | `GitOpsWithPSCore-Smith` |
| Slide decks | `SessionTitle-SpeakerLastName.pptx` | `GitOpsWithPSCore-Smith.pptx` |
| Code/demo files | Descriptive, kebab-case | `deploy-pipeline.ps1` |
| No spaces | Use hyphens or underscores | ✅ `my-demo.ps1` ❌ `my demo.ps1` |

- Keep all filenames lowercase where possible
- Avoid special characters other than hyphens (`-`) and underscores (`_`)

---

## 🚀 How to Submit Your Materials

1. **Fork** this repository to your own GitHub account
2. **Clone** your fork locally:
   ```bash
   git clone https://github.com/YOUR-USERNAME/REPO-NAME.git
   ```
3. **Create a folder** for your session following the naming conventions above
4. **Add your materials** — slides, code, demos, etc.
5. **Commit and push** to your fork:
   ```bash
   git add .
   git commit -m "Add session materials: Your Session Title"
   git push origin main
   ```
6. **Open a Pull Request** against the `main` branch of this repo
   - Use your session title as the PR title
   - Add a brief description of what's included

---

## 🗣️ Speakers & Sessions

| Speaker | Session Title | Track |
|---|---|---|

*This table will be updated as sessions are confirmed.*

---

## 🤝 Code of Conduct

This repository, and the Summit itself follows, our **Code of Conduct**. We are committed to providing a welcoming, inclusive, and respectful environment for all speakers and attendees.

- Be respectful in all interactions, including PR reviews and comments
- No discriminatory, harassing, or exclusionary language or content
- Keep all materials professional and appropriate for a broad technical audience
- Violations can be reported to *(add contact email)*

By submitting materials to this repo, you agree to abide by this Code of Conduct.

---

## ❓ Questions?

Reach out to the organizing team by opening a [GitHub Issue](../../issues).

We're excited to have you as part of the Summit! 🎉
