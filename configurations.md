# Construir a imagem Docker
podman build -t nginx-image-labs .

# Executar o contêiner Docker
podman run -d --name nginx-labs -p 8081:8081 nginx-image-labs

# Removendo
podman rm -f nginx-labs
podman rmi -f nginx-image-labs