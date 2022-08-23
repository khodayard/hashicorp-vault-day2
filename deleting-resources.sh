#Entities und Aliases
clear
echo "Schrit 1: Räumung alle Entities,Groups und ihre Aliases:"
echo "################################################"
echo "Wir sind gerade hier:"
echo Vault Address: $VAULT_ADDR
echo Vault Namespace: $VAULT_NAMESPACE
echo "################################################"

ental_list=$(vault list identity/entity-alias/id | tail -n +3)
ental_count=$(vault list identity/entity-alias/id | tail -n +3 | wc -l)
ent_list=$(vault list identity/entity/id | tail -n +3)
ent_count=$(vault list identity/entity/id | tail -n +3 | wc -l)
gral_list=$(vault list identity/group-alias/id | tail -n +3)
gral_count=$(vault list identity/group-alias/id | tail -n +3 | wc -l)
gr_list=$(vault list identity/group/id | tail -n +3)
gr_count=$(vault list identity/group/id | tail -n +3 | wc -l)

echo Anzahl Entitiy Aliases : $ental_count
echo Anzahl Entities        : $ent_count
echo Anzahl Group Aliases   : $gral_count
echo Anzahl Groups          : $gr_count
read -p "Alle löschen? (y/n)?" choice
case "$choice" in
    y|Y ) echo "Result:";
    for ental_id in $ental_list
    do
        vault delete identity/entity-alias/id/$ental_id 
    done
    for ent_id in $ent_list
    do
        vault delete identity/entity/id/$ent_id 
    done
    for gral_id in $gral_list
    do
        vault delete  identity/group-alias/id/$gral_id 
    done
    for gr_id in $gr_list
    do
        vault delete identity/group/id/$gr_id 
    done
    ;;
    * ) echo "Abgesagt.";;
esac

#PKI Secret Engines
clear
echo "Schrit 2: Räumung alle PKI Secret Engines und ihre Certificate:"
echo "################################################"
echo "Wir sind gerade hier:"
echo Vault Address: $VAULT_ADDR
echo Vault Namespace: $VAULT_NAMESPACE
echo "################################################"

pki_list=$(vault secrets list | grep pki | cut -f 1 -d /)
for pki_eng in $pki_list; 
do
    cert_list=$(vault list $pki_eng/certs| tail -n +3)
    cert_count=$(vault list $pki_eng/certs| tail -n +3| wc -l)
    echo PKI: $pki_eng
    echo Anzahl Zertifikate: $cert_count
    read -p "Alle Revoke und PKI Tidy machen? (y/n)?" choice
    case "$choice" in
        y|Y ) echo "Result:";
            for cert_ins in $cert_list
                do
                    vault write $pki_eng/revoke serial_number=$cert_ins 
                done
            vault write $pki_eng/tidy tidy_cert_store=true tidy_revoked_certs=true safety_buffer='1s'
        ;;
        * ) echo "Abgesagt.";;
    esac
done

#KV Secret Engines
clear
echo "Schrit 3: Räumung alle Secret Engines und ihre Secrets:"
echo "################################################"
echo "Wir sind gerade hier:"
echo Vault Address: $VAULT_ADDR
echo Vault Namespace: $VAULT_NAMESPACE
echo "################################################"

kv_list=$(vault secrets list | grep kv | cut -d " " -f 1| tr "\n" " ")

for kv_eng in $kv_list
do
    secret_path_list=$(vault kv list $kv_eng | tail -n +3 | tr "\n" " ")
    echo Secret Lists in $kv_eng: $secret_path_list
    read -p "Alle löschen? (y/n)?" choice
    case "$choice" in
        y|Y ) echo "Result:";
            for sec_path in $secret_path_list
            do
                    vault kv metadata delete $kv_eng$sec_path
            done
        ;;
        * ) echo "Abgesagt.";;
    esac
    read -p "Secret Engine $kv_eng selbst auch löschen? (y/n)?" choice
    case "$choice" in
        y|Y ) echo "Result:";
            vault secrets disable $kv_eng
        ;;
        * ) echo "Abgesagt.";;
    esac
done

#Leases
clear
echo "Schrit 4: Räumung alle Leases:"
echo "################################################"
echo "Wir sind gerade hier:"
echo Vault Address: $VAULT_ADDR
echo Vault Namespace: $VAULT_NAMESPACE
echo "################################################"

get_leases(){ curl -s --header "X-Vault-Token: $VAULT_TOKEN" --header "X-Vault-Namespace: $VAULT_NAMESPACE" --request LIST $VAULT_ADDR/v1/sys/leases/lookup/$1 | jq -r .data.keys[] ;}
get_leases_path(){ get_leases $1 | grep -x '.\{3,70\}' ;}
count_leases(){ get_leases $1 | grep -x '.\{70,75\}' | wc -l ;}

lease_path_list=$(bash lease-path-list.sh)
for lease_path in $lease_path_list
do
    lease_count=$(count_leases $lease_path)
    lease_list=$(get_leases $lease_path)
    echo Lease Path: $lease_path
    echo Anzahl Leases: $lease_count
    read -p "Alle löschen? (y/n)?" choice
    case "$choice" in
        y|Y ) echo "Result:";
            for lease_ins in $lease_list
            do
                    vault lease revoke $lease_path/$lease_ins 
            done
        ;;
        * ) echo "Abgesagt.";;
    esac
done

#Policies
clear
echo "Schrit 2: Räumung alle Policies:"
echo "################################################"
echo "Wir sind gerade hier:"
echo Vault Address: $VAULT_ADDR
echo Vault Namespace: $VAULT_NAMESPACE
echo "################################################"

pol_list=$(vault policy list | tr "\n" " ")
echo Policies List: $pol_list
read -p "Alle löschen? (y/n)?" choice
case "$choice" in
    y|Y ) echo "Result:";
        for pol_name in $pol_list
        do
            vault policy delete $pol_name 
        done
    ;;
    * ) echo "Abgesagt.";;
esac
