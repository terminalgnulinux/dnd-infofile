#!/bin/bash

#-----------------------------------------------------------#
# Data: 12 de Agosto de 2016
# Nome: Juliano Santos  [x_SHAMAN_x]
# Script: dnd-infofile
# Descrição: Obtem informações detalhadas do arquivo.
#-----------------------------------------------------------#

# A imagem utilizada no script é baixada do repositório do git diretamente para a pasta '/tmp'
# no objetivo de manter apenas o arquivo do script sem imagens em anexo, deixando
# a critério do usuário, modificá-la. Basta alterar o valor da variavel 'IMG_PATH'
# com diretório da imagem de sua preferência e comentar a linha 'wget'
wget https://raw.githubusercontent.com/terminalgnulinux/dnd-infofile/master/ask.png -O /tmp/ask.png /tmp &>/dev/null

# Splash imagem
# O pinguim que tudo sabe, visivel na janela principal.
IMG_PATH=/tmp/ask.png

# Função que obtem informações do arquivo
function GetFileInfo()
{
	local FILE="${1/file:\/\/}"	# Obtem do 'uri' o caminho do arquivo
	local FILENAME="${FILE##*/}"	# Extrai o nome do arquivo
	local -a __FILE_INFO				# Array
	
	# Define o delimitador
	IFS='|'
	
	# Lê as informações do arquivo em 'FILE', obtidas pelo comando 'stat' na formatação especificada
	# nos parametros do comando e imprimidos pelo comando 'printf'
	# Os formatos foram separados pelo delimitador definido em 'IFS'
	for info in $(stat --printf "%a|%A|%B|%d|%D|%f|%F|%g|%G|%u|%U|%s|%x|%y|%z" "$FILE"); do
		# Adiciona a cada indice do array o valor armazenado em 'info'
		FILE_INFO+=("$info"); done
	
	# Limpa 
	unset IFS

	# Janela 'Informações do arquivo'
	# Preenche os campos com os elementos contidos em 'FILE_INFO'	
	yad --form \
		--center \
		--fixed \
		--width 900 \
		--height 400 \
		--no-buttons \
		--columns 2 \
		--title "[x_SHAMAN_x] dnd-infofile - Informações do arquivo" \
		--field "<b>Local</b>":LBL '' \
		--field "Arquivo:":RO "$FILENAME" \
		--field "Caminho:":RO "${FILE%/*}" \
		--field '':LBL '' \
		--field "<b>Descrição</b>":LBL '' \
		--field "Tipo:":RO "$(file "$FILE" | cut -d':' -f2-)" \
		--field "Extensão:":RO "$(echo "$FILE" | sed -n 's/.*\.//pg')" \
		--field '<b>Permissões</b>':LBL '' \
		--field "Octal:":RO "${FILE_INFO[0]}" \
		--field "Humano:":RO "[${FILE_INFO[1]}]" \
		--field "Grupo (ID):":RO "${FILE_INFO[7]}" \
		--field "Grupo (Name):":RO "${FILE_INFO[8]}" \
		--field "Usuario (ID):":RO "${FILE_INFO[9]}" \
		--field "Usuário (Name):":RO "${FILE_INFO[10]}" \
		--field '':LBL '' \
		--field '<b>Tamanho</b>':LBL '' \
		--field "Bytes:":RO "${FILE_INFO[11]}" \
		--field "Humano:":RO "$(du -hs "$FILE" | awk '{print $1}')" \
		--field '':LBL '' \
		--field '<b>Acesso</b>':LBL '' \
		--field "Acessado em:":RO "${FILE_INFO[12]}" \
		--field "Modificado em:":RO "${FILE_INFO[13]}" \
		--field "Atualizado em:":RO "${FILE_INFO[14]}" \
		--field "<b>Sistema</b>":LBL '' \
		--field "Num. Blocks":RO "${FILE_INFO[2]} bytes" \
		--field "Num. Dispositivo (dec)":RO "${FILE_INFO[3]}" \
		--field "Num. Dispositivo (hex)":RO "${FILE_INFO[4]}" \
		--field "Modo RAW (hex)":RO "${FILE_INFO[5]}" \
		--field 'Abrir arquivo!gtk-open':BTN "xdg-open '$FILE'" \
		--field '':LBL '' 
			
}

# Inicia a janela 'drag-n-drop'.
# Quando o arquivo é arrastado para a jenala, seu 'path' é redicionado
# para a saida padrão, onde é lido pelo 'while', que chama a função
# 'GetFileInfo' passando o camainho do arquivo como parâmetro.
yad --dnd \
		--geometry +0+0 \
		--fixed \
		--on-top \
		--no-buttons \
		--title "O que é ?" \
		--text "Arraste seu arquivo pra cá." \
		--tooltip \
		--image "$IMG_PATH" \
		--image-on-top | while read file; do
						 	GetFileInfo "$file"; done	# Chama a função


# Fim
