# 🐦 SaralVaani: Standalone Multi-Input AI Translation Suite

SaralVaani is a lightweight, fully autonomous multimedia pipeline built for Windows environments. It bridges digital accessibility gaps by converting diverse inputs (**Text documents, Audio captures, or Video clips**) into localized Indian regional dialects. 

Designed purposefully for offline hackathon evaluations and limited hardware deployments, the entire infrastructure runs natively on a **standard CPU architecture** without demanding high-end discrete GPUs.

---

## 🚀 Key Architectural Capabilities

*   **🎙️ Intelligent Audio Transcription:** Powered by an integrated `OpenAI Whisper` engine to scan and decode wave structures directly from files.
*   **📡 Neural Machine Translation Matrix:** Harnesses Meta AI's `NLLB-200 (600M Distilled Model)` to parse 400-word chunk sequences into 11+ distinct Indian regional sub-dialects.
*   **🔊 Audio Dubbing & Gender Profiling:** Modulates text-to-speech outputs through speed-invariant pitch filters to balance target voice characteristics (Male/Female options).
*   **🎬 Automated Multi-Stream Video Alignment:** Generates perfectly aligned Subtitle tracks (`.srt`) alongside audio-video re-muxing to output a fully dubbed media clip.
*   **📂 Multi-Format Export Package:** Synchronously exports comprehensive data packages containing `.txt`, `.docx`, and `.pdf` documents directly to your local file system.

---

## 🛠️ Supported Indian Dialects
The underlying translation engine natively supports mapping to:
*   **Hindi** (`hin_Deva`) | **Telugu** (`tel_Telu`) | **Tamil** (`tam_Knda`) | **Kannada** (`kan_Knda`)
*   **Malayalam** (`mal_Mlym`) | **Bengali** (`ben_Beng`) | **Marathi** (`mar_Deva`) | **Gujarati** (`guj_Gujr`)
*   **Punjabi** (`pan_Guru`) | **Odia** (`ory_Orya`) | **Assamese** (`asm_Asmv`)

---

## 📦 Zero-Configuration Windows Installation

SaralVaani features a completely automated, system-agnostic deployment environment. You do not need to manually configure your paths, users, or virtual dependencies.

### Installation Instructions:
1. Open a **PowerShell** terminal window with **Administrative Privileges**.
2. Execute the environment bootstrap script file:
```powershell
   & "C:\Path\To\Your\SaralVaani.ps1"
