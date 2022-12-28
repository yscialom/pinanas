color()  { printf "\033[%sm${2}\033[0m\n" "${1}"; }
red()    { color "0;31" "$*" ; }
yellow() { color "0;33" "$*" ; }
green()  { color "0;32" "$*" ; }

log ()  { echo "$(basename "$0") [$1] $2" >&2 ; }
info()  { log " $(green INFO)"  "$*" ; }
cont()  { log "     "           "$*" ; }
warn()  { log " $(yellow WARN)" "$*" ; }
error() { log "$(red ERROR)"    "$*" ; }
fatal() { log "$(red FATAL)"    "$(red "$@")" ; }

function curl_ () {
    docker run --rm --net host \
        -v /tmp/letsencrypt-stg-root-x1.pem:/tmp/letsencrypt-stg-root-x1.pem:ro \
        curlimages/curl:7.77.0 \
        --cacert /tmp/letsencrypt-stg-root-x1.pem "$@"
}

function test_field () {
    local field="${1}"
    local url="${2}"
    local actual="${3}"
    local expected="${4}"
    local silent="${5}"

    if [[ ${actual} != ${expected} ]] ; then
        [[ ${silent} != "yes" ]] && error "'${url}': ${field}: '${actual}'; expected: '${expected}'."
        return 10
    fi
}

function web_expect () {
    local url="${1}"
    shift

    # get tests options
    local opt OPTARG OPTIND # required as to not be set in the global namespace and affect subsequent calls
    while getopts "sc:r:" opt ; do
        case "${opt}" in
        s) local silent=yes ;;
        c) local expected_http_code=${OPTARG} ;;
        r) local expected_redirect_url=${OPTARG} ;;
        *) error "Unknown option ${opt}." ; exit 1 ;;
        esac
    done

    # request
    response=$(mktemp)
    curl_ --silent --output /dev/null --write-out '%{json}' "${url}" >${response}

    # check curl status
    test_field exit_status "${url}" $? 0 ${silent} || return

    # check response
    if [[ -n ${expected_http_code} ]] ; then
        local actual_http_code=$(jq .http_code <${response})
        test_field http_code "${url}" ${actual_http_code} ${expected_http_code} ${silent} || return
    fi

    # check redirect
    if [[ -n ${expected_redirect_url} ]] ; then
        local actual_redirect_url=$(jq -r '.redirect_url | tostring' <${response})
        test_field redirect_url "${url}" ${actual_redirect_url} ${expected_redirect_url} ${silent} || return
    fi
}

function api_expect () {
    local url="${1}"
    shift

    # get tests options
    declare -a curl_options
    while getopts "c:l:q:" opt ; do
        case "${opt}" in
        c) curl_options+=(${OPTARG}) ;; # do not quote OPTARG here!
        l) local expected_length=${OPTARG} ;;
        q) local query="${OPTARG}" ;;
        *) error "Unknown option ${opt}." ; exit 1 ;;
        esac
    done

    # request
    response=$(mktemp)
    curl_ --silent --header "Accept: application/json" "${curl_options[@]}" "${url}" >${response}

    # check curl status
    test_field exit_status "${url}" $? 0 || return

    # check length
    if [[ -n ${expected_length} ]] ; then
        local actual_length=$(jq '. | length' <${response})
        test_field length "${url}" ${actual_length} ${expected_length} || return
    fi

    # check query
    if [[ -n ${query} ]] ; then
        local result=$(jq "${query}" <${response})
        test_field "${query}" "${url}" "${result}" true || return
    fi
}

function html_expect () {
    local url="${1}"
    shift

    # get tests options
    while getopts "r:" opt ; do
        case "${opt}" in
        r) local regex=${OPTARG} ;;
        *) error "Unknown option ${opt}." ; exit 1 ;;
        esac
    done

    # request & search
    curl_ --silent --location "${url}" | grep -Eq "${regex}"
}
