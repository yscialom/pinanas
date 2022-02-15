function error () {
    echo "$(basename $0): error: $1" >&2
}

function test_field () {
    local field="${1}"
    local url="${2}"
    local actual="${3}"
    local expected="${4}"

    if [[ "${actual}" != "${expected}" ]] ; then
        error "'${url}': ${field}: '${actual}'; expected: '${expected}'."
        return 10
    fi
}

function web_expect () {
    local url="${1}"
    shift

    # get tests options
    while getopts "c:r:" opt ; do
        case "${opt}" in
        c) local expected_http_code=${OPTARG} ;;
        r) local expected_redirect_url=${OPTARG} ;;
        *) error "Unknown option ${opt}." ; exit 1 ;;
        esac
    done

    # request
    response=$(mktemp)
    docker run --rm --net host curlimages/curl:7.77.0 --silent --output /dev/null --write-out '%{json}' "${url}" >${response}

    # check curl status
    test_field exit_status "${url}" $? 0 || exit $?

    # check response
    if [[ -n ${expected_http_code} ]] ; then
        local actual_http_code=$(jq .http_code <${response})
        test_field http_code "${url}" ${actual_http_code} ${expected_http_code} || exit $?
    fi

    # check redirect
    if [[ -n ${expected_redirect_url} ]] ; then
        local actual_redirect_url=$(jq -r '.redirect_url | tostring' <${response})
        test_field redirect_url "${url}" ${actual_redirect_url} ${expected_redirect_url} || exit $?
    fi

    rm -- "${response}"
}

function api_expect () {
    local url="${1}"
    shift

    # get tests options
    while getopts "l:" opt ; do
        case "${opt}" in
        l) local expected_length=${OPTARG} ;;
        *) error "Unknown option ${opt}." ; exit 1 ;;
        esac
    done

    # request
    response=$(mktemp)
    docker run --rm --net host curlimages/curl:7.77.0 --silent "${url}" >${response}

    # check curl status
    test_field exit_status "${url}" $? 0 || exit $?

    # check length
    if [[ -n ${expected_length} ]] ; then
        local actual_length=$(jq '. | length' <${response})
        test_field length "${url}" ${actual_length} ${expected_length} || exit $?
    fi

    rm -- "${response}"
}
