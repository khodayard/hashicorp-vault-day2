get_leases(){ curl -s --header "X-Vault-Token: $VAULT_TOKEN" --header "X-Vault-Namespace: $VAULT_NAMESPACE" --request LIST $VAULT_ADDR/v1/sys/leases/lookup/$1 | jq -r .data.keys[] 2>/dev/null;}
get_leases_path(){ get_leases $1 | grep -x '.\{3,70\}' ;}
count_leases(){ get_leases $1 | grep -x '.\{70,75\}' | wc -l ;}
get_leases_path | 
	while read p1
	do
		if [ $(count_leases $p1) -gt 0 ]; then echo $p1; fi
		get_leases_path $p1 | 
			while read p2
			do 
				if [ $(count_leases $p1$p2) -gt 0 ]; then echo $p1$p2; fi
				get_leases_path $p1$p2 | 
					while read p3
					do
						if [ $(count_leases $p1$p2$p3) -gt 0 ]; then echo $p1$p2$p3; fi
						get_leases_path $p1$p2$p3 | 
							while read p4
							do
								if [ $(count_leases $p1$p2$p3$p4) -gt 0 ]; then echo $p1$p2$p3$p4; fi
								get_leases_path $p1$p2$p3$p4 |
									while read p5
									do
										if [ $(count_leases $p1$p2$p3$p4$p5) -gt 0 ]; then echo $p1$p2$p3$p4$p5; fi
										get_leases_path $p1$p2$p3$p4$p5
									done
							done
					done
			done
	done
