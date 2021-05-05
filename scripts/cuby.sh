#!/bin/bash
#CUBY (Create Users By) crea y elimina usuarios por lotes
#Christian Mosquera 1ºSMR CPIFP The Links ZGZ

#evalúa si se ha introducido un parametro y ejecuta el script. 
#de lo contrario ofrece la ayuda.

if [ ${1} ]; then 

#datetime para la generación de logs
datetime=$(date "+%Y-%m-%d-%H:%M:%S")

	case $1 in
	#muestra la ayuda
	'-h') 	cat ~/scripts/40txt.txt;;

	#genera usuarios de forma secuencial
	#$0 - nombre del script
	#$1 - opcion
	#$2 - cantidad
	#$3 - nombre usuario
	#$4 - nombre grupo
	#$5 - password
	#$6 - shell
	#$7 - comentario

	'-n') for ((i=1;i<=$2;i++));
	      do
	      sudo groupadd -f $4$i
              sudo useradd -g $4$i -s /bin/$6 -m -p $5 -c $7 $3$i
              echo "$i,$3$i,$4$i,$5,$6,$7" >>  ~/scripts/log-$datetime.txt
	      done
	      echo "se han creado los siguientes usuarios y grupos:"
	      cat ~/scripts/log-$datetime.txt;;

	#genera usuarios a partir de una lista
	'-f')   lineas="$(cat ~/scripts/import-users.txt | wc -l)"
	        echo "se han cargado $lineas usuarios"	
		for ((i=1;i<=$lineas;i++));
                do
		usuario="$(awk NR==$i ~/scripts/import-users.txt | awk -F',' '{print $2}')";
		grupo="$(awk NR==$i ~/scripts/import-users.txt | awk -F','  '{print $3}')";
		contrasena="$(awk NR==$i ~/scripts/import-users.txt | awk -F','  '{print $4}')";
		nombre="$(awk NR==$i ~/scripts/import-users.txt | awk -F','  '{print $5}')";
		shell="$(awk NR==$i ~/scripts/import-users.txt | awk -F','  '{print $6}')";
		coment="$(awk NR==$i ~/scripts/import-users.txt | awk -F','  '{print $7}')";
		echo "usuario: $usuario - grupo: $grupo - contraseña: $contrasena - nombre: $nombre - shell: $shell - comentarios: $coment"
                done

		#confirma que se crearan los usuarios
		read -p "Desea iniciar la creación de estos usuarios? 1=si / 2=no: " opcion;

		#reinicia las variables para eliminar el ultimo registro
		unset usuario;
		unset grupo;
		unset contrasena;
		unset nombre;
		unset shell;
		unset coment;

		case $opcion in
		2) echo "se ha cancelado la creación de usuarios"
		   exit;;
		1) for ((e=1;e<=$lineas;e++))
			do
			usuario="$(awk NR==$e ~/scripts/import-users.txt | awk -F','  '{print $2}')";
			grupo="$(awk NR==$e ~/scripts/import-users.txt | awk -F','  '{print $3}')";
			contrasena="$(awk NR==$e ~/scripts/import-users.txt | awk -F','  '{print $4}')";
			nombre="$(awk NR==$e ~/scripts/import-users.txt | awk -F','  '{print $5}')";
			shell="$(awk NR==$e ~/scripts/import-users.txt | awk -F','  '{print $6}')";
			coment="$(awk NR==$e ~/scripts/import-users.txt | awk -F','  '{print $7}')";
			sudo groupadd -f $grupo
			sudo useradd -g $grupo -s /bin/$shell -m -p $contrasena -c "$coment" $usuario
			echo "$e,$usuario,$grupo,$contrasena,$nombre,$shell,$coment" >>  ~/scripts/log-$datetime.txt
			done;;
		esac
		echo "Se han creado $lineas usuarios y grupos con los siguientes detalles:"
   		cat ~/scripts/log-$datetime.txt;;

	#genera usuarios a partir de un rango dado
	'-r') #$0 - nombre del script
              #$1 - opcion
              #$2 - rango inicial
	      #$3 - rango final
              #$4 - nombre usuario
              #$5 - nombre grupo
              #$6 - password
              #$7 - shell
              #$8 - comentario

	        for ((i=$2;i<=$3;i++));
                do
		sudo groupadd -f $5$i
                sudo useradd -g $4$i -s /bin/$7 -m -p $6 -c $8 $4$i
                echo "$i,$4$i,$5$i,$6,$7,$8" >>  ~/scripts/log-$datetime.txt
                done
                echo "se han creado los siguientes usuarios y grupos:"
                cat ~/scripts/log-$datetime.txt;;


	#genera usuarios usando numeros aleatorios entre 1 y 999
	'-rand') #$0 - nombre del script
              #$1 - opcion
              #$2 - cantidad
              #$3 - nombre usuario
              #$4 - nombre grupo
              #$5 - password
              #$6 - shell
              #$7 - comentario

		for ((i=1;i<=$2;i++));
                do
		r=$((1 + RANDOM % 999))
		sudo groupadd -f $4$r
                sudo useradd -g $4$r -s /bin/$6 -m -p $5 -c $7 $3$r
                echo "$i,$3$r,$4$r,$5,$6,$7" >>  ~/scripts/log-$datetime.txt
                done
                echo "se han creado los siguientes usuarios y grupos:"
                cat ~/scripts/log-$datetime.txt;;
	
	#elimina usuarios y grupos segun un log generado	
	'-del') fichero=$2
		lineas="$(cat ~/scripts/$fichero | wc -l)"
                echo "se han cargado $lineas usuarios"  
                for ((i=1;i<=$lineas;i++));
                do
                usuario="$(awk NR==$i ~/scripts/$fichero | awk -F',' '{print $2}')";
                grupo="$(awk NR==$i ~/scripts/$fichero | awk -F','  '{print $3}')";
                echo "usuario: $usuario - grupo: $grupo"
                done

		#confirma que se eliminaran los usuarios
                read -p "Desea iniciar la eliminación de estos usuarios y grupos?  1=si / 2=no: " opcion;

                #reinicia las variables para eliminar el ultimo registro
                unset usuario;
                unset grupo;

		 case $opcion in
                2) echo "se ha cancelado la eliminación de usuarios"
                   exit;;
                1) for ((e=1;e<=$lineas;e++))
                        do
                        usuario="$(awk NR==$e ~/scripts/$fichero | awk -F','  '{print $2}')";
                        grupo="$(awk NR==$e ~/scripts/$fichero | awk -F','  '{print $3}')";
                        sudo userdel -r  $usuario
			sudo groupdel $grupo
                        done;;
                esac
		sudo rm -R ~/scripts/$fichero
                echo "Se han eliminado $lineas usuarios y grupos"
                echo "se ha eliminado el  fichero $fichero"

	esac

else 
	echo "no ha introducido ningun paramentro"
	echo "escriba  -h para ver la ayuda"

fi
