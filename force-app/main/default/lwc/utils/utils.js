const getPriority = () => {
    return [
        { label: 'P1', value: p1 },
        { label: 'P2', value: p2 },
        { label: 'P3', value: p3 }
    ];
};

const truncateText = (str) => {
    return truncatedVal = str.split(" ").splice(0,10).join(" ");
};

export { getPriority, truncateText };