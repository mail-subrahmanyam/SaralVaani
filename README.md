# 🐦 SaralVaani: Enterprise Standalone Multi-Input AI Translation Suite

SaralVaani is an enterprise-grade, fully autonomous multimedia localization pipeline engineered for secure, air-gapped Windows environments. It bridges digital accessibility gaps by converting diverse corporate data assets (**Text documents, Audio captures, and Video assets**) into localized Indian regional dialects. 

Designed purposefully for high-efficiency on-premise deployment, the entire infrastructure runs natively on **standard CPU architectures**, removing dependencies on high-end discrete GPUs while maintaining predictable throughput and strict data privacy.

---

## 🚀 Key Architectural Capabilities

* **🎙️ Enterprise Audio Transcription:** Powered by an optimized, local instance of the `OpenAI Whisper` engine to scan and decode wave structures directly from high-density media files.
* **📡 Neural Machine Translation Matrix:** Harnesses Meta AI's `NLLB-200 (600M Distilled Model)` to parse 400-word chunk sequences into 11+ distinct Indian regional dialects with state-of-the-art BLEU scores.
* **🔊 Professional Dubbing & Gender Profiling:** Modulates text-to-speech outputs through speed-invariant pitch filters to dynamically balance target voice characteristics (Male/Female profiles).
* **🎬 Automated Multi-Stream Video Alignment:** Generates synchronized Subtitle tracks (`.srt`) alongside programmatic audio-video re-muxing to output a production-ready, fully dubbed media clip.
* **📂 Structured Multi-Format Export Package:** Synchronously exports comprehensive data packages containing `.txt`, `.docx`, and `.pdf` documents directly to your local file system or network-attached storage (NAS).

---

## 🛠️ Supported Indian Dialects

The underlying translation engine natively supports mapping to:
* **Hindi** (`hin_Deva`) | **Telugu** (`tel_Telu`) | **Tamil** (`tam_Knda`) | **Kannada** (`kan_Knda`)
* **Malayalam** (`mal_Mlym`) | **Bengali** (`ben_Beng`) | **Marathi** (`mar_Deva`) | **Gujarati** (`guj_Gujr`)
* **Punjabi** (`pan_Guru`) | **Odia** (`ory_Orya`) | **Assamese** (`asm_Asmv`)

---

## 📦 Zero-Configuration Windows Deployment

SaralVaani features a completely automated, system-agnostic deployment environment suited for enterprise rollouts. System administrators can execute the automated bootstrap script to handle dependencies, virtual environment provisioning, and local model pathing without manual intervention.

### Deployment Instructions:

1. Open a **PowerShell** terminal window with **Administrative Privileges**.
2. Restrict execution policy to the current process scope for secure deployment:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
3. Execute in power shell **& "C:\Path\To\Your\SaralVaani.ps1"**
