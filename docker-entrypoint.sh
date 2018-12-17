et -e
 
if [ "${1:0:1}" = '-' ]; then
    set -- elasticsearch "$@"
fi
 
if [ "$1" = 'elasticsearch' -a "$(id -u)" = '0' ]; then
    chown -R elasticsearch:elasticsearch /usr/local/elasticsearch-6.1.3/data
    set -- gosu elasticsearch "$@"
fi
 
exec "$@"





