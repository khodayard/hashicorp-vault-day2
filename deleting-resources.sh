#Entities und Aliases


ental_list=$(vault list identity/entity-alias/id 2>/dev/null | tail -n +3)
ental_count=$(vault list identity/entity-alias/id 2>/dev/null | tail -n +3 | wc -l)
ent_list=$(vault list identity/entity/id 2>/dev/null | tail -n +3)
ent_count=$(vault list identity/entity/id 2>/dev/null | tail -n +3 | wc -l)
gral_list=$(vault list identity/group-alias/id 2>/dev/null | tail -n +3)
gral_count=$(vault list identity/group-alias/id 2>/dev/null | tail -n +3 | wc -l)
gr_list=$(vault list identity/group/id 2>/dev/null | tail -n +3)
gr_count=$(vault list identity/group/id 2>/dev/null | tail -n +3 | wc -l)

if [ $ental_count -gt 0 ] || [ $ent_count -gt 0 ] || [ $gral_count -gt 0 ] || [ $gr_count -gt 0 ] ; then
    clear -x
    echo "Räumung alle Entities,Groups und ihre Aliases:"
    echo "################################################"
    echo "Wir sind gerade hier:"
    echo Vault Address: $VAULT_ADDR
    echo Vault Namespace: $VAULT_NAMESPACE
    echo "################################################"
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
fi

#PKI Secret Engines

pki_list=$(vault secrets list | grep pki | cut -f 1 -d /)
for pki_eng in $pki_list; 
do
    clear -x
    echo "Räumung alle PKI Secret Engines Roles und ihre Certificate:"
    echo "################################################"
    echo "Wir sind gerade hier:"
    echo Vault Address: $VAULT_ADDR
    echo Vault Namespace: $VAULT_NAMESPACE
    echo "################################################"
    roles_list=$(vault list $pki_eng/roles | tail -n +3)
    cert_list=$(vault list $pki_eng/certs | tail -n +3 | tr "\n" " ")
    cert_count=$(vault list $pki_eng/certs | tail -n +3| wc -l)
    echo "####################CERTS#######################"
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
    echo "#####################ROLES#######################"
    echo PKI: $pki_eng
    echo Role List: $roles_list
    read -p "Alle löschen? (y/n)?" choice
    case "$choice" in
        y|Y ) echo "Result:";
            for role_ins in $roles_list
                do
                    vault delete $pki_eng/roles/$role_ins
                done
        ;;
        * ) echo "Abgesagt.";;
    esac
done

#KV Secret Engines

kv_list=$(vault secrets list | grep kv | cut -d " " -f 1| tr "\n" " ")

for kv_eng in $kv_list
do
    clear -x
    echo "Räumung alle Secret Engines und ihre Secrets:"
    echo "################################################"
    echo "Wir sind gerade hier:"
    echo Vault Address: $VAULT_ADDR
    echo Vault Namespace: $VAULT_NAMESPACE
    echo "################################################"
    secret_path_list=$(vault kv list $kv_eng  2>/dev/null | tail -n +3 | tr "\n" " ")
    secret_path_count=$(vault kv list $kv_eng  2>/dev/null | tail -n +3 | wc -l)
    echo Secret Lists in $kv_eng: $secret_path_list
    echo Secret Count in $kv_eng: $secret_path_count
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

#Transit Secret Engines
tr_list=$(vault secrets list | grep transit | cut -d " " -f 1 | tr "\n" " ")
tr_count=$(vault secrets list | grep transit | cut -d " " -f 1 | wc -l)

if [ $tr_count -gt 0 ] ; then
    clear -x
    echo "Räumung alle Transit Secret Engines:"
    echo "################################################"
    echo "Wir sind gerade hier:"
    echo Vault Address: $VAULT_ADDR
    echo Vault Namespace: $VAULT_NAMESPACE
    echo "################################################"
    echo Transit Secret Engine: $tr_list
    read -p "Alle löschen? (y/n)?" choice
    case "$choice" in
        y|Y ) echo "Result:";
            for tr_eng in $tr_list
            do
                vault secrets disable $tr_eng
            done
        ;;
        * ) echo "Abgesagt.";;
    esac
fi

#Auth Methods

auth_list=$(vault auth list | grep -v token| cut -d " " -f 1 | tail -n +3 | tr "\n" " ")
auth_count=$(vault auth list | grep -v token| cut -d " " -f 1 | tail -n +3 | wc -l)

if [ $auth_count -gt 0 ] ; then
    clear -x
    echo "Räumung alle Auth Methods:"
    echo "################################################"
    echo "Wir sind gerade hier:"
    echo Vault Address: $VAULT_ADDR
    echo Vault Namespace: $VAULT_NAMESPACE
    echo "################################################"
    echo Auth Methods: $auth_list
    read -p "Alle löschen? (y/n)?" choice
    case "$choice" in
        y|Y ) echo "Result:";
            for auth_method in $auth_list
            do
                vault auth disable $auth_method
            done
        ;;
        * ) echo "Abgesagt.";;
    esac
fi

#Leases

get_leases(){ curl -s --header "X-Vault-Token: $VAULT_TOKEN" --header "X-Vault-Namespace: $VAULT_NAMESPACE" --request LIST $VAULT_ADDR/v1/sys/leases/lookup/$1 | jq -r .data.keys[] ;}
get_leases_path(){ get_leases $1 | grep -x '.\{3,70\}' ;}
count_leases(){ get_leases $1 | grep -x '.\{70,75\}' | wc -l ;}

lease_path_list=$(bash lease-path-list.sh)
for lease_path in $lease_path_list
do
clear -x
    echo "Räumung alle Leases:"
    echo "################################################"
    echo "Wir sind gerade hier:"
    echo Vault Address: $VAULT_ADDR
    echo Vault Namespace: $VAULT_NAMESPACE
    echo "################################################"
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

pol_list=$(vault policy list | grep -v default | tr "\n" " ")
pol_count=$(vault policy list | grep -v default | wc -l)

if [ $pol_count -gt 0 ] ; then
    clear -x
    echo "Räumung alle Policies:"
    echo "################################################"
    echo "Wir sind gerade hier:"
    echo Vault Address: $VAULT_ADDR
    echo Vault Namespace: $VAULT_NAMESPACE
    echo "################################################"
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
fi
