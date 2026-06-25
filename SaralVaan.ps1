# ==========================================
# SYSTEM-AGNOSTIC ENVIRONMENT INTERROGATOR
# ==========================================
# 1. Look for Python in the known layout first, otherwise search system PATH natively (ignoring Windows Store aliases)
$KnownPythonPath = "C:\Users\Lenovo\AppData\Local\Programs\Python\Python310\python.exe"

if (Test-Path $KnownPythonPath) {
    $PythonExe = $KnownPythonPath
} else {
    $PythonExe = Get-Command python.exe -ErrorAction SilentlyContinue | 
                 Where-Object { $_.Source -notmatch "WindowsApps" } | 
                 Select-Object -ExpandProperty Source -First 1
}

if (-not $PythonExe -or -not (Test-Path $PythonExe)) {
    Write-Host "❌ CRITICAL ERROR: A valid Python installation could not be verified on this computer!" -ForegroundColor Red
    Exit
}

Write-Host "🐍 Utilizing Python core binary found at: $PythonExe" -ForegroundColor Cyan

# 2. Dynamically build sandbox relative to active downloads directory
if (Test-Path "C:\Users\Lenovo\Downloads") {
    $DownloadsDir = "C:\Users\Lenovo\Downloads"
} else {
    $DownloadsDir = Join-Path $env:USERPROFILE "Downloads"
}
$TargetDir = Join-Path $DownloadsDir "Hackathon\SaralVaani"

Write-Host "🎯 Target Deployment Path resolved to: $TargetDir" -ForegroundColor Cyan

# 3. WORKSPACE SCAFFOLDING 
$Folders = @(
    $TargetDir,
    (Join-Path $TargetDir "src\ui"),
    (Join-Path $TargetDir "output\exports")
)
foreach ($Folder in $Folders) {
    if (-not (Test-Path $Folder)) { 
        New-Item -ItemType Directory -Path $Folder -Force | Out-Null
    }
}

# 4. FORCE-KILL LOCKED HANDLES & CLEAN VENV
Write-Host "⚠️ Flushing sandbox workspace to clean file handles..." -ForegroundColor Yellow
Stop-Process -Name "python" -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

Set-Location -Path $TargetDir

if (Test-Path ".\venv") {
    try {
        Remove-Item -Recurse -Force .\venv -ErrorAction Stop
    } catch {
        Write-Host "🔄 Venv folder locked. Attempting rename bypass..." -ForegroundColor Yellow
        Rename-Item -Path ".\venv" -NewName "venv_old_$(Get-Date -Format 'HHmmss')" -ErrorAction SilentlyContinue
    }
}

# 5. LIGHTWEIGHT CPU-ONLY DEPENDENCY INGESTION (Warnings Completely Muted)
Write-Host "[1/2] Rebuilding fresh isolated Python sandbox environment..." -ForegroundColor Yellow
& $PythonExe -m venv venv 2>$null

Write-Host "[2/2] Installing offline AI backend tools (CPU Static Build)..." -ForegroundColor Yellow
# --quiet flag and 2>$null redirects ignore pip/wheels upgrade warnings entirely
& .\venv\Scripts\pip install customtkinter transformers sentencepiece torch soundfile librosa moviepy python-docx reportlab gTTS scipy --extra-index-url https://download.pytorch.org/whl/cpu --quiet --no-warn-script-location 2>$null

# 6. INJECTING END-TO-END PIPELINE SYSTEM CODE
Write-Host "Injecting production CPU desktop engine code..." -ForegroundColor Yellow

$UIAppCode = @"
import tkinter as tk
import customtkinter as ctk
from tkinter import filedialog, messagebox
import threading
import os
import math
import time
import re
import warnings

# Mute all runtime Hugging Face and library-level warning arrays
warnings.filterwarnings("ignore")
os.environ["TOKENIZERS_PARALLELISM"] = "false"

# System/Media Engine Libraries
import soundfile as sf
import librosa
import numpy as np
from scipy.io import wavfile
from moviepy import VideoFileClip, AudioFileClip

from docx import Document
from reportlab.lib.pagesizes import letter
from reportlab.pdfgen import canvas
from gtts import gTTS

# AI Infrastructure
import torch
from transformers import AutoModelForSeq2SeqLM, AutoTokenizer, pipeline

ctk.set_appearance_mode("System")
ctk.set_default_color_theme("blue")

NLLB_LANG_MAP = {
    "Hindi": "hin_Deva", "Telugu": "tel_Telu", "Tamil": "tam_Knda", 
    "Kannada": "kan_Knda", "Malayalam": "mal_Mlym", "Bengali": "ben_Beng", 
    "Marathi": "mar_Deva", "Gujarati": "guj_Gujr", "Punjabi": "pan_Guru",
    "Odia": "ory_Orya", "Assamese": "asm_Asmv"
}

class SaralVaaniApp(ctk.CTk):
    def __init__(self):
        super().__init__()
        
        self.device = "cpu"
        self.device_id = -1
        
        self.title("SaralVaani - Standalone AI Suite [CPU Engine]")
        self.geometry("1050x750")
        self.minsize(950, 700)
        
        self.selected_file_path = None
        
        self.header_frame = ctk.CTkFrame(self, height=75, corner_radius=0)
        self.header_frame.pack(fill="x", side="top")
        
        self.logo_label = ctk.CTkLabel(
            self.header_frame, 
            text="🐦 SaralVaani Multi-Input Translation Suite (CPU Build)", 
            font=ctk.CTkFont(size=20, weight="bold")
        )
        self.logo_label.pack(side="left", padx=25, pady=15)
        
        self.main_container = ctk.CTkFrame(self, fg_color="transparent")
        self.main_container.pack(fill="both", expand=True, padx=20, pady=20)
        
        self.left_panel = ctk.CTkFrame(self.main_container, width=450)
        self.left_panel.pack(side="left", fill="both", expand=True, padx=(0, 10))
        
        self.drop_title = ctk.CTkLabel(self.left_panel, text="File Input & Target Selectors", font=ctk.CTkFont(size=17, weight="bold"))
        self.drop_title.pack(pady=12)
        
        self.upload_btn = ctk.CTkButton(self.left_panel, text="📁 Choose File (TXT, MP3, WAV, MP4, MKV)", command=self.select_file, height=50)
        self.upload_btn.pack(pady=15, padx=20)
        
        self.file_status_label = ctk.CTkLabel(self.left_panel, text="No active workspace file selected", font=ctk.CTkFont(slant="italic", size=13))
        self.file_status_label.pack(pady=5, padx=15)
        
        self.voice_label = ctk.CTkLabel(self.left_panel, text="Target Voice Gender Modulation Profile:", font=ctk.CTkFont(size=13, weight="bold"))
        self.voice_label.pack(anchor="w", padx=25, pady=(15, 2))
        self.voice_menu = ctk.CTkOptionMenu(self.left_panel, values=["Female Voice Model", "Male Voice Model"])
        self.voice_menu.pack(fill="x", padx=25, pady=5)
        
        self.burn_subs_var = tk.StringVar(value="off")
        self.burn_subs_chk = ctk.CTkCheckBox(self.left_panel, text="Hardburn subtitles directly into output video clip", variable=self.burn_subs_var, onvalue="on", offvalue="off")
        self.burn_subs_chk.pack(pady=(25, 10), padx=25, anchor="w")

        self.right_panel = ctk.CTkFrame(self.main_container, width=450)
        self.right_panel.pack(side="right", fill="both", expand=True, padx=(10, 0))
        
        self.config_title = ctk.CTkLabel(self.right_panel, text="Pipeline Parameters & Outputs Matrix", font=ctk.CTkFont(size=17, weight="bold"))
        self.config_title.pack(pady=12)
        
        self.lang_label = ctk.CTkLabel(self.right_panel, text="Target Indian Language Translation Dialect:", font=ctk.CTkFont(size=13))
        self.lang_label.pack(anchor="w", padx=35, pady=(5, 2))
        self.lang_menu = ctk.CTkOptionMenu(self.right_panel, values=list(NLLB_LANG_MAP.keys()))
        self.lang_menu.pack(fill="x", padx=35, pady=5)
        
        self.matrix_frame = ctk.CTkFrame(self.right_panel)
        self.matrix_frame.pack(fill="x", padx=35, pady=15, ipady=10)
        
        self.matrix_title = ctk.CTkLabel(self.matrix_frame, text="Target Output Compilations (All Checked by Default)", font=ctk.CTkFont(size=12, weight="bold"), text_color="#17A2B8")
        self.matrix_title.pack(anchor="w", padx=20, pady=(10, 5))
        
        self.out_txt_var = tk.BooleanVar(value=True)
        self.out_audio_var = tk.BooleanVar(value=True)
        self.out_video_var = tk.BooleanVar(value=True)
        
        self.chk_txt = ctk.CTkCheckBox(self.matrix_frame, text="Generate Text Packages (TXT, DOCX, PDF)", variable=self.out_txt_var)
        self.chk_txt.pack(anchor="w", padx=20, pady=8)
        
        self.chk_audio = ctk.CTkCheckBox(self.matrix_frame, text="Generate Audio Targets (ASR Speech transcript + Synthesized Audio)", variable=self.out_audio_var)
        self.chk_audio.pack(anchor="w", padx=20, pady=8)
        
        self.chk_video = ctk.CTkCheckBox(self.matrix_frame, text="Generate Video Targets (Muted + Rendered Dub + SRT Subs)", variable=self.out_video_var)
        self.chk_video.pack(anchor="w", padx=20, pady=8)
        
        self.progress_frame = ctk.CTkFrame(self.right_panel, fg_color="transparent")
        self.progress_frame.pack(fill="x", padx=35, pady=(20, 5))
        
        self.progress_status_label = ctk.CTkLabel(self.progress_frame, text="System Core State: Idle", font=ctk.CTkFont(size=13, weight="bold"), text_color="gray")
        self.progress_status_label.pack(anchor="w", pady=2)
        
        self.progress_bar = ctk.CTkProgressBar(self.progress_frame, orientation="horizontal", mode="determinate")
        self.progress_bar.set(0)
        self.progress_bar.pack(fill="x", pady=5)
        
        self.process_btn = ctk.CTkButton(self.right_panel, text="🚀 Execute Standalone Pipeline", fg_color="#1E7E34", hover_color="#19692C", height=50, font=ctk.CTkFont(size=15, weight="bold"), command=self.start_processing_thread)
        self.process_btn.pack(side="bottom", fill="x", padx=35, pady=25)
        
    def select_file(self):
        file_path = filedialog.askopenfilename(filetypes=[("All Supported Assets", "*.txt *.mp3 *.wav *.mp4 *.mkv")])
        if file_path:
            self.selected_file_path = file_path
            self.file_status_label.configure(text=f"Selected Local File:\n{os.path.basename(file_path)}")
            
    def start_processing_thread(self):
        if not self.selected_file_path:
            messagebox.showwarning("Missing Input Target", "Please load a source asset file before triggering execution.")
            return
        threading.Thread(target=self.execute_inference_pipeline, daemon=True).start()

    def remove_consecutive_repetitions(self, text):
        if not text:
            return ""
        text = re.sub(r'\b(\w+)(?:\s+\1\b)+', r'\1', text, flags=re.IGNORECASE)
        text = re.sub(r'\b(.+?)(?:\s+\1\b)+', r'\1', text, flags=re.IGNORECASE)
        return text

    def generate_srt(self, text, duration, srt_path):
        def format_time(seconds):
            hours = int(seconds // 3600)
            minutes = int((seconds % 3600) // 60)
            secs = int(seconds % 60)
            millis = int((seconds - int(seconds)) * 1000)
            return f"{hours:02d}:{minutes:02d}:{secs:02d},{millis:03d}"
        
        words = text.split()
        chunk_size = max(1, len(words) // 5)
        chunks = [words[i:i + chunk_size] for i in range(0, len(words), chunk_size)]
        
        with open(srt_path, "w", encoding="utf-8") as f:
            for index, chunk in enumerate(chunks):
                start = (duration / len(chunks)) * index
                end = (duration / len(chunks)) * (index + 1)
                caption = " ".join(chunk)
                f.write(f"{index + 1}\n{format_time(start)} --> {format_time(end)}\n{caption}\n\n")

    def execute_inference_pipeline(self):
        temp_audio_path = None
        try:
            self.process_btn.configure(state="disabled", text="⏳ Instantiating CPU Registers...", fg_color="#D39E00")
            self.progress_bar.set(0.05)
            
            ext = os.path.splitext(self.selected_file_path)[1].lower()
            
            user_downloads = os.path.join(os.path.expanduser("~"), "Downloads")
            export_dir = os.path.join(user_downloads, "Hackathon", "SaralVaani", "output", "exports")
            
            base_name = os.path.splitext(os.path.basename(self.selected_file_path))[0]
            chosen_language = self.lang_menu.get()
            target_lang_code = NLLB_LANG_MAP[chosen_language]
            voice_selection = self.voice_menu.get()
            
            source_text = ""
            media_duration = 10.0 
            
            if ext == ".txt":
                self.progress_status_label.configure(text="Reading text document payload...", text_color="#17A2B8")
                with open(self.selected_file_path, 'r', encoding='utf-8') as f:
                    source_text = f.read().strip()
            else:
                self.progress_status_label.configure(text="Extracting audio stream context...", text_color="#17A2B8")
                self.progress_bar.set(0.15)
                
                temp_audio_path = os.path.join(export_dir, f"temp_stream_{int(time.time())}.wav")
                if ext in [".mp4", ".mkv"]:
                    video_clip = VideoFileClip(self.selected_file_path)
                    media_duration = video_clip.duration
                    video_clip.audio.write_audiofile(temp_audio_path, logger=None)
                    video_clip.close()
                else:
                    audio_clip = AudioFileClip(self.selected_file_path)
                    media_duration = audio_clip.duration
                    audio_clip.write_audiofile(temp_audio_path, logger=None)
                    audio_clip.close()
                
                self.progress_status_label.configure(text="Loading OpenAI Whisper-Tiny...", text_color="#17A2B8")
                self.progress_bar.set(0.25)
                
                asr_pipe = pipeline(
                    "automatic-speech-recognition", 
                    model="openai/whisper-tiny", 
                    chunk_length_s=30,
                    device=self.device_id
                )
                
                self.progress_status_label.configure(text="Transcribing wave structures via CPU...", text_color="#17A2B8")
                self.progress_bar.set(0.40)
                
                audio_array, sampling_rate = librosa.load(temp_audio_path, sr=16000)
                asr_result = asr_pipe({"raw": audio_array, "sampling_rate": sampling_rate})
                source_text = asr_result["text"].strip()
                    
            if not source_text:
                raise ValueError("Could not decode speech text patterns from source material.")
            
            self.progress_status_label.configure(text="Loading NLLB-200 Matrix onto CPU...", text_color="#17A2B8")
            self.progress_bar.set(0.55)
            
            model_id = "facebook/nllb-200-distilled-600M"
            tokenizer = AutoTokenizer.from_pretrained(model_id)
            model = AutoModelForSeq2SeqLM.from_pretrained(model_id).to(self.device)
            
            try:
                forced_bos_id = tokenizer.lang_code_to_id[target_lang_code]
            except AttributeError:
                forced_bos_id = tokenizer.vocab.get(target_lang_code)
                
            if forced_bos_id is None:
                raise ValueError(f"Could not resolve vocabulary ID for language code: {target_lang_code}")
            
            self.progress_status_label.configure(text="Translating text arrays natively via CPU...", text_color="#17A2B8")
            
            words = source_text.split()
            chunk_word_size = 400
            text_chunks = [" ".join(words[i:i + chunk_word_size]) for i in range(0, len(words), chunk_word_size)]
            translated_pieces = []
            
            for index, text_chunk in enumerate(text_chunks):
                if not text_chunk.strip():
                    continue
                inputs = tokenizer(text_chunk, return_tensors="pt").to(self.device)
                
                translated_tokens = model.generate(
                    **inputs, 
                    forced_bos_token_id=forced_bos_id, 
                    max_length=512,
                    repetition_penalty=1.3,
                    no_repeat_ngram_size=4
                )
                chunk_out = tokenizer.batch_decode(translated_tokens, skip_special_tokens=True)[0]
                translated_pieces.append(chunk_out)
                
            raw_translated_text = " ".join(translated_pieces)
            translated_text = self.remove_consecutive_repetitions(raw_translated_text)
            self.progress_bar.set(0.70)
            
            if self.out_txt_var.get():
                self.progress_status_label.configure(text="Compiling text file export packages...", text_color="#17A2B8")
                txt_out = os.path.join(export_dir, f"{base_name}_Translated_{chosen_language}.txt")
                docx_out = os.path.join(export_dir, f"{base_name}_Translated_{chosen_language}.docx")
                pdf_out = os.path.join(export_dir, f"{base_name}_Translated_{chosen_language}.pdf")
                
                with open(txt_out, "w", encoding="utf-8") as f:
                    f.write(translated_text)
                    
                doc = Document()
                doc.add_heading("SaralVaani Multi-Lingual Export Pipeline Document", 0)
                doc.add_paragraph(f"Target Sub-dialect Index Flag: {chosen_language}")
                doc.add_paragraph(translated_text)
                doc.save(docx_out)
                
                pdf_canvas = canvas.Canvas(pdf_out, pagesize=letter)
                pdf_canvas.setFont("Helvetica-Bold", 16)
                pdf_canvas.drawString(50, 750, "SaralVaani Multi-Lingual Offline Document Export")
                pdf_canvas.setFont("Helvetica", 12)
                pdf_canvas.drawString(50, 720, f"Target Language Profile: {chosen_language}")
                
                text_object = pdf_canvas.beginText(50, 680)
                text_object.setFont("Helvetica", 10)
                for chunk in [translated_text[i:i+80] for i in range(0, len(translated_text), 80)]:
                    text_object.textLine(chunk)
                pdf_canvas.drawText(text_object)
                pdf_canvas.save()
            
            tts_audio_path = os.path.join(export_dir, f"{base_name}_VoiceOver_{chosen_language}.mp3")
            if self.out_audio_var.get() or self.out_video_var.get():
                self.progress_status_label.configure(text="Rendering Anti-Warp Voice-Over Synthesizer...", text_color="#17A2B8")
                
                punctuated_text = translated_text.replace(" ", ", ", len(translated_text.split()) // 4)
                
                raw_tts_path = os.path.join(export_dir, "raw_tts_temp.mp3")
                tts = gTTS(text=punctuated_text, lang='hi' if chosen_language == "Hindi" else 'en', slow=False) 
                tts.save(raw_tts_path)
                
                y, sr = librosa.load(raw_tts_path, sr=None)
                speed_factor = 0.82 if "Male" in voice_selection else 1.12
                new_sr = int(sr / speed_factor)
                
                sf.write(tts_audio_path, y, new_sr, format='mp3')
                
                if os.path.exists(raw_tts_path):
                    os.remove(raw_tts_path)
                
            if self.out_video_var.get() and ext in [".mp4", ".mkv"]:
                self.progress_status_label.configure(text="Mapping audio/video multi-stream alignments...", text_color="#17A2B8")
                srt_out_path = os.path.join(export_dir, f"{base_name}_Subtitles_{chosen_language}.srt")
                self.generate_srt(translated_text, media_duration, srt_out_path)
                
                input_video = VideoFileClip(self.selected_file_path)
                translated_voiceover = AudioFileClip(tts_audio_path)
                
                final_video = input_video.with_audio(translated_voiceover)
                final_output_video_path = os.path.join(export_dir, f"{base_name}_FinalDubbed_{chosen_language}.mp4")
                
                final_video.write_videofile(final_output_video_path, codec="libx264", audio_codec="aac", logger=None)
                
                input_video.close()
                translated_voiceover.close()
                final_video.close()
                
            if temp_audio_path and os.path.exists(temp_audio_path):
                os.remove(temp_audio_path)
                
            self.progress_bar.set(1.0)
            self.progress_status_label.configure(text="Execution Success! Outputs written safely.", text_color="#28A745")
            self.process_btn.configure(state="normal", text="🚀 Execute Standalone Pipeline", fg_color="#1E7E34")
            
            messagebox.showinfo("Pipeline Run Success", f"Task Complete! Independent hardware outputs generated inside:\n\n{export_dir}")
            
        except Exception as e:
            if temp_audio_path and os.path.exists(temp_audio_path):
                os.remove(temp_audio_path)
            self.progress_status_label.configure(text="Pipeline Error encountered.", text_color="red")
            self.process_btn.configure(state="normal", text="🚀 Execute Standalone Pipeline", fg_color="#1E7E34")
            messagebox.showerror("Hardware Pipeline Failure", f"An internal device exception occurred:\n{str(e)}")

if __name__ == "__main__":
    app = SaralVaaniApp()
    app.mainloop()
"@

$UIAppCode | Out-File -FilePath (Join-Path $TargetDir "src\ui\main_window.py") -Encoding utf8

# 7. GENERATING THE DOUBLE-CLICKABLE LAUNCH SCRIPT (.BAT) IN THE APPLICATION ROOT
Write-Host "Creating local launcher execution script..." -ForegroundColor Yellow
$BatFile = Join-Path $TargetDir "Run_SaralVaani.bat"

$BatContents = @"
@echo off
title SaralVaani Desktop App Runtime Launcher
cd /d "%~dp0"
echo [System Integration] Activating isolated Python sandbox workspace...
call .\venv\Scripts\activate
echo [System Integration] Bootstrapping UI runtime layers...
python .\src\ui\main_window.py
pause
"@

$BatContents | Out-File -FilePath $BatFile -Encoding ascii

Write-Host "`n=======================================================" -ForegroundColor Green
Write-Host "🎉 Environment configured successfully on this system!" -ForegroundColor Green
Write-Host "📂 Application Directory: $TargetDir" -ForegroundColor Cyan
Write-Host "🚀 Launch Shortcut Created locally: $BatFile" -ForegroundColor Cyan
Write-Host "=======================================================" -ForegroundColor Green

& .\venv\Scripts\python .\src\ui\main_window.py
