export function isWarning(value) {
    return typeof value === 'string' && value.toLowerCase() === 'warning';
}

export function isError(value) {
    return typeof value === 'string' && value.toLowerCase() === 'error';
}