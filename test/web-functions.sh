function error () {
    echo "$(basename $0): error: $1" >&2
}

function test_exit_status () {
    local name=$1
    local actual=$2
    local expected=$3
    if [[ ${actual} != ${expected} ]] ; then
        error "'${name}': exit_status: ${actual}; expected: ${expected}."
        exit 2
    fi
}

function test_http_code () {
    local url="${1}"
    local actual=$2
    local expected=$3

    if [[ ${actual} != ${expected} ]] ; then
        error "'${url}': http_code: ${actual}; expected: ${expected}."
        exit 3
    fi
}

function web_expect () {
    local url="${1}"
    shift

    # get tests options
    while getopts "c:H:" opt ; do
        case "${opt}" in
        c) local expected_http_code=${OPTARG} ;;
        H) local expected_header=${OPTARG} ;;
        *) echo "$0: error: Unknown option ${opt}." ; exit 1 ;;
        esac
    done

    # request
    response=$(mktemp)
    docker run --rm --net host curlimages/curl:7.77.0 --silent --output /dev/null --write-out '%{json}' "${url}" >${response}

    # check curl status
    test_exit_status curl $? 0 || exit $?

    # check response
    if [[ -n ${expected_http_code} ]] ; then
        local actual_http_code=$(jq .http_code <${response})
        test_http_code "${url}" ${actual_http_code} ${expected_http_code} || exit $?
    fi

    # check redirect
    # TODO
}
