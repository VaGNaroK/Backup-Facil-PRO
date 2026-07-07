import os
import sys
import subprocess
import ctypes
import threading
import shutil
import time

def is_admin_or_root():
    """Verifica se o usuário tem privilégios de Administrador/Root."""
    try:
        if os.name == 'nt':
            return ctypes.windll.shell32.IsUserAnAdmin() != 0
        else:
            return os.geteuid() == 0
    except:
        return False

def listar_discos_fisicos():
    """
    Lista os discos físicos disponíveis no sistema para escaneamento.
    Retorna uma lista de dicionários com 'path' e 'description'.
    """
    discos = []
    if os.name == 'nt':
        # Usa wmic para listar discos no Windows
        try:
            output = subprocess.check_output(
                ["wmic", "diskdrive", "get", "deviceid,model,size", "/format:csv"],
                creationflags=subprocess.CREATE_NO_WINDOW if hasattr(subprocess, 'CREATE_NO_WINDOW') else 0
            ).decode('utf-8', errors='ignore')
            lines = output.strip().split('\n')
            for line in lines[1:]: # pula cabeçalho
                if line.strip():
                    parts = line.split(',')
                    if len(parts) >= 4:
                        device_id = parts[1].strip()
                        model = parts[2].strip()
                        size_bytes = parts[3].strip()
                        try:
                            size_gb = round(int(size_bytes) / (1024**3), 2)
                            desc = f"{model} ({size_gb} GB)"
                        except ValueError:
                            desc = model
                        discos.append({'path': device_id, 'description': desc})
        except Exception as e:
            print(f"Erro ao listar discos no Windows: {e}")
    else:
        # Usa lsblk no Linux
        try:
            output = subprocess.check_output(["lsblk", "-d", "-n", "-o", "NAME,MODEL,SIZE"]).decode('utf-8', errors='ignore')
            for line in output.strip().split('\n'):
                if line.strip():
                    parts = line.split(maxsplit=2)
                    if len(parts) >= 3:
                        name = f"/dev/{parts[0]}"
                        model = parts[1]
                        size = parts[2]
                        discos.append({'path': name, 'description': f"{model} ({size})"})
                    elif len(parts) == 2:
                        name = f"/dev/{parts[0]}"
                        size = parts[1]
                        discos.append({'path': name, 'description': f"({size})"})
        except Exception as e:
            print(f"Erro ao listar discos no Linux: {e}")
            
    return discos

def verificar_dependencias_forenses():
    """Verifica se o photorec está instalado/acessível."""
    photorec_cmd = "photorec_win.exe" if os.name == "nt" else "photorec"
    return shutil.which(photorec_cmd) is not None

def executar_photorec(alvo_path, destino_path, callback_log=None, callback_status=None):
    """
    Executa o PhotoRec em modo batch (linha de comando).
    """
    # Exceção: se for um arquivo de imagem normal não requer admin. Se for raw requer.
    # Assumimos raw por padrão se começar com /dev ou \\.\
    requer_admin = str(alvo_path).startswith("/dev") or str(alvo_path).startswith("\\\\.\\")
    
    if requer_admin and not is_admin_or_root():
        if callback_log: callback_log("❌ ERRO CRÍTICO: Privilégios de Administrador/Root necessários para acessar discos físicos.\nDica: Rode o Backup Fácil Pro como Administrador.")
        if callback_status: callback_status(False)
        return False

    photorec_cmd = ["photorec_win.exe"] if os.name == "nt" else ["photorec"]
    
    in_flatpak = os.path.exists("/.flatpak-info")
    if in_flatpak:
        photorec_cmd = ["flatpak-spawn", "--host", "photorec"]
        # Se for um disco raw no flatpak, força elevação pelo host
        if requer_admin:
            photorec_cmd = ["flatpak-spawn", "--host", "pkexec", "photorec"]

    # Verifica dependência (simplificado, no flatpak confiamos no host)
    if not in_flatpak and not shutil.which(photorec_cmd[0]):
        if callback_log: callback_log("❌ ERRO: 'photorec' não foi encontrado no sistema.\nNo Linux: sudo apt install testdisk\nNo Windows: Baixe o TestDisk e coloque 'photorec_win.exe' na raiz.")
        if callback_status: callback_status(False)
        return False

    if not os.path.exists(destino_path):
        os.makedirs(destino_path, exist_ok=True)

    if callback_log: callback_log(f"🕵️ Iniciando File Carving via PhotoRec...\nAlvo: {alvo_path}\nDestino: {destino_path}")
    
    cmd = photorec_cmd + ["/d", destino_path, "/cmd", alvo_path, "partition_none,search"]
    
    try:
        creationflags = 0
        if os.name == 'nt':
            creationflags = 0x08000000 # CREATE_NO_WINDOW
            
        process = subprocess.Popen(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            creationflags=creationflags
        )
        
        while True:
            line = process.stdout.readline()
            if not line and process.poll() is not None:
                break
            if line and callback_log:
                line_clean = line.strip()
                if line_clean:
                    # Filtramos linhas irrelevantes
                    if "Pass" in line_clean or "recovered" in line_clean or "Error" in line_clean or "PhotoRec" in line_clean:
                        callback_log(line_clean)
                        
        return_code = process.poll()
        sucesso = (return_code == 0)
        
        if sucesso:
            if callback_log: callback_log("✅ Varredura profunda finalizada com sucesso!\nVerifique as subpastas criadas na pasta de destino escolhida.")
        else:
            if callback_log: callback_log(f"⚠️ A varredura profunda terminou ou foi interrompida (Código: {return_code}).")
            
        if callback_status: callback_status(sucesso)
        return sucesso
        
    except Exception as e:
        if callback_log: callback_log(f"❌ Exceção ao rodar PhotoRec: {str(e)}")
        if callback_status: callback_status(False)
        return False
