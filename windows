cat > ad-dc-setup.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

# ====== EDITA ESTOS VALORES ======
HOSTNAME_SHORT="SB-USVR"          # TusIniciales-USVR
DNS_DOMAIN="sb.local"             # Ej: sb.local
NETBIOS_DOMAIN="SB"               # Ej: SB
SERVER_IP_CIDR="192.168.56.10/24" # IP del DC
SERVER_IP="192.168.56.10"
DNS_FORWARDER="8.8.8.8"           # o tu gateway/DNS
IFACE="enp0s8"                    # interfaz del adaptador del dominio
ADMINPASS="A123456a"              # según tu enunciado
# =================================

KERBEROS_REALM="$(echo "$DNS_DOMAIN" | tr '[:lower:]' '[:upper:]')"

echo "[1/8] Hostname..."
sudo hostnamectl set-hostname "$HOSTNAME_SHORT"

echo "[2/8] /etc/hosts..."
sudo cp /etc/hosts /etc/hosts.bak
sudo bash -c "cat > /etc/hosts" <<H
127.0.0.1 localhost
127.0.1.1 ${HOSTNAME_SHORT}.${DNS_DOMAIN} ${HOSTNAME_SHORT}
${SERVER_IP} ${HOSTNAME_SHORT}.${DNS_DOMAIN} ${HOSTNAME_SHORT}

# IPv6
::1 ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
H

echo "[3/8] Paquetes..."
sudo apt update
sudo apt install -y samba-ad-dc krb5-user bind9-dnsutils smbclient winbind

echo "[4/8] Parar/inhabilitar servicios clásicos..."
sudo systemctl disable --now smbd nmbd winbind || true
sudo systemctl mask smbd nmbd winbind || true
sudo systemctl unmask samba-ad-dc || true
sudo systemctl enable samba-ad-dc

echo "[5/8] Provisionar dominio (esto puede tardar)..."
if [ -f /etc/samba/smb.conf ]; then
  sudo mv /etc/samba/smb.conf "/etc/samba/smb.conf.orig.$(date +%F_%H%M%S)"
fi

sudo samba-tool domain provision \
  --realm="$KERBEROS_REALM" \
  --domain="$NETBIOS_DOMAIN" \
  --server-role=dc \
  --dns-backend=SAMBA_INTERNAL \
  --use-rfc2307 \
  --adminpass="$ADMINPASS" \
  --host-name="$HOSTNAME_SHORT" \
  --host-ip="$SERVER_IP" \
  --option="interfaces=lo $IFACE" \
  --option="bind interfaces only=yes" \
  --option="dns forwarder = $DNS_FORWARDER"

echo "[6/8] Kerberos conf + resolv.conf..."
sudo cp /var/lib/samba/private/krb5.conf /etc/krb5.conf

sudo systemctl disable --now systemd-resolved || true
sudo rm -f /etc/resolv.conf
sudo bash -c "cat > /etc/resolv.conf" <<R
nameserver 127.0.0.1
search ${DNS_DOMAIN}
R

echo "[7/8] Arrancar samba-ad-dc..."
sudo systemctl restart samba-ad-dc
sudo systemctl --no-pager --full status samba-ad-dc || true

echo "[8/8] Info dominio (GUARDA EL SID)..."
sudo samba-tool domain info "$(hostname -f)" || true

echo "LISTO. Si todo fue bien, ahora configura el W10 con DNS=$SERVER_IP y únete a ${DNS_DOMAIN}."
EOF

chmod +x ad-dc-setup.sh
sudo ./ad-dc-setup.sh
