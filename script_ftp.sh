#!/bin/bash 

# nom : script_sftp
# date : 01/01/2024 
# auteur : David UNG 
# description : Outil permettant à un administrateur de gérer un petit serveur SFTP

# Prérequis : 
# - Créer le groupe qui va acceuillir les utilisateurs sftp 
# - Créer un répertoire d'acceuil qui va contenir tous les utilisateurs sftp
# - Changer les droits 
# chmod 750 /home/sftp_home
# - Configuration du fichier /etc/ssh/sshd_config pour réaliser le chroot
#overttide default of no subsystems 
# Subsystem sftp internal-sftp
#
# Match Group sftp_user
#	X11Forwarding no
#	AllowTcpForwarding no 
#	PermitTTY no 
#	PermitTunnel no 
#	ForceCommand internal-sftp -d /upload
#	ChrootDirectory /home/sftp_home/%u		

# Vérifier si l'utilisateur est root :
if [ "$(id -u)" -ne 0 ]; then
    echo "Ce script doit être exécuté en tant que superutilisateur (root)." >&2
    exit 1
fi

# Création de l'utilisateur : 

# Demander le nom de l'utilisateur à créer 
echo "Entrez le nom du nouvel utilisateur :" 
read user_name

# Créer l'utilisateur avec les spécifications (sans shell, le répertoire dans sftp_home et membre du groupe sftp_user)
sudo useradd -m -s /usr/sbin/nologin -d /home/sftp_home/"$user_name" -G sftp_user "$user_name"

# Modifier le propriétaire et le groupe du répertoire home de l'utilisateur
sudo chown root:sftp_user /home/sftp_home/"$user_name"

# Définir les permissions sur le répertoire home de l'utilisateur 
sudo chmod 750 /home/sftp_home/"$user_name"

# Créer le sous-répertoire 'upload' dans le répertoire de l'utilisateur 
sudo mkdir /home/sftp_home/"$user_name"/upload

# Modifier le propriétaire du répertoire 'upload' pour l'utilisateur 
sudo chown "$user_name":"$user_name" /home/sftp_home/"$user_name"/upload

# Lien symbolique 
sudo ln -s /var/www/"$nom_dossier" /home/sftp_home/"$user_name"/upload

# Définir les permissions sur le répertoire 'upload' de l'utilisateur 
sudo chmod 750 /home/sftp_home/"$user_name"/upload

# Générer un mit de apsse aléatoire avec OpenSSL 
password=$(openssl rand -base64 8)

# Assigner le mot de passe à l'utilisateur 
sudo echo "$user_name:$password" | chpasswd

# Enregistrer les identifiants dans un fichier txt, dans le répertoire de l'admin
file_path="/home/admin/${user_name}_password.txt"
{
	echo "Bonjour, "
	echo ""
	echo "Suite à votre commande, voici vos identifiants afin d'accéder à votre espace : "
	echo "Nom d'utilisateur : $user_name"
	echo "Mot de passe : $password"
	echo ""
	echo "Veuillez nous contacter si vous rencontrez des problèmes"
	echo "Cordialement,"
	echo ""
	echo "Votre équipe support, "
} > "$file_path"

# Modifier les permissions du fichier pour que seul l'admin puisse le lire 
sudo chown admin:admin "$file_path"
sudo chmod 600 "$file_path" 
