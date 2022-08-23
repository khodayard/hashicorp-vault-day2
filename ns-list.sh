vault namespace list -namespace=$vns | egrep -v "Keys|---" | 
	while read n1
	do
	    echo $vns$n1	
		vault namespace list -namespace=$vns$n1 | egrep -v "Keys|---" | 
			while read n2
			do
				echo $vns$n1$n2
				vault namespace list -namespace=$vns$n1$n2 | egrep -v "Keys|---" | 
					while read n3
					do 
						echo $vns$n1$n2$n3
						vault namespace list -namespace=$vns$n1$n2$n3 | egrep -v "Keys|---" |
							while read n4
							do
								echo $vns$n1$n2$n3$n4
								vault namespace list -namespace=$vns$n1$n2$n3$n4 | egrep -v "Keys|---" 
							done
					done
			done
	done 2>/dev/null > nss
