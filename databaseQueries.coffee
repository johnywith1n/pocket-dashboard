exports.combineQueries = (queries) ->
    result = {}
    for query in queries
        for key, value of query
            result[key] = value
    return result

exports.getUnarchived = () ->
    return {status : "0" }

exports.getArchived = () ->
    return {status : "1"}

exports.getAll = () ->
    return {}

exports.getWithUrlRegex = (urlRegex) ->
    return {resolved_url : urlRegex}

