var schema = {
    type: "object",
    id: "pinanas",
    title: "pinanas",
    description: "PiNanas Settings",
    required: [ "domain", "master_secret", "timezone", "users", "network" ],
    properties: {
        domain: {
            type: "string",
            description: "Registered domain name",
            pattern: "^(([A-Za-z0-9])+\\.?)+$",
        },
        ports: {
            type: "object",
            description: "Port numbers",
            properties: {
                http: {
                    type: "integer",
                    title: "HTTP port",
                    minimum: 1,
                    maximum: 65535,
                },
                https: {
                    type: "integer",
                    description: "HTTPS port",
                    minimum: 1,
                    maximum: 65535,
                },
            },
        },
        master_secret: {
            type: "string",
            description: "Master password to encrypt/derive all PiNanas secrets",
        },
        timezone: {
            type: "string",
            description: "Locale timezone",
        },
        users: {
            type: "array",
            description: "Users",
            items: {
                type: "object",
                title: "user",
                description: "User",
                required: [ "login", "password", "email" ],
                properties: {
                    login: {
                        type: "string",
                        description: "User login",
                    },
                    password: {
                        type: "string",
                        description: "User password",
                    },
                    email: {
                        type: "string",
                        description: "User email",
                    },
                    fullname: {
                        type: "string",
                        description: "User fullname",
                    },
                },
            },
        },
        services: {
            type: "array",
            description: "External services",
            items: {
                type: "object",
                title: "service",
                description: "External service",
                required: [ "name", "url" ],
                properties: {
                    name: {
                        type: "string",
                        description: "Service subdomain",
                        pattern: "^[A-Za-z0-9]+$",
                    },
                    url: {
                        type: "string",
                        description: "Service url",
                        pattern: "https?://[A-Za-z0-9-_.]+(:[0-9]+)?(/.*)?$",
                    },
                },
            },
        },
        acme: {
            type: "object",
            description: "ACME options",
            required: [ "stagging" ],
            properties: {
                stagging: {
                    type: "string",
                    enum: [ "true", "false" ],
                    description: "Use Let's Encrypt stagging servers",
                    default: "false",
                    format: "radio",
                }
            }
        },
        network: {
            type: "object",
            description: "Network options",
            required: [ "dns", "smtp" ],
            properties: {
                dhcp: {
                    type: "object",
                    description: "dhcp",
                    properties: {
                        hmac: {
                            type: "string",
                            description: "MAC address of PiNana's host network card",
                            pattern: "^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$",
                        },
                        ip: {
                            type: "string",
                            description: "Desired IP address of PiNanas's host",
                            pattern: "^[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+$",
                        },
                        base: {
                            type: "string",
                            description: "Base IP for the network",
                            pattern: "^[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+$",
                        },
                        subnet: {
                            type: "string",
                            description: "Network subnet mask",
                            pattern: "^[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+$",
                        },
                        gateway: {
                            type: "string",
                            description: "Network gateway",
                            pattern: "^[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+$",
                        },
                        range: {
                            type: "object",
                            description: "DHCP range",
                            properties: {
                                start: {
                                    type: "string",
                                    description: "First (included) IP of clients inside the network",
                                    pattern: "^[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+$",
                                },
                                end: {
                                    type: "string",
                                    description: "Last (included) IP of clients inside the network",
                                    pattern: "^[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+$",
                                },
                            }
                        },
                        fixed_address_leases: {
                            type: "array",
                            description: "Fixed-address leases",
                            items: {
                                type: "object",
                                title: "fixed-address lease",
                                description: "Fixed-address lease",
                                required: [ "name", "hmac", "ip" ],
                                properties: {
                                    name: {
                                        type: "string",
                                        description: "Device name",
                                    },
                                    hmac: {
                                        type: "string",
                                        description: "Device MAC address",
                                        pattern: "^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$",
                                    },
                                    ip: {
                                        type: "string",
                                        description: "Device IP address",
                                    },
                                },
                            },
                        },
                    },
                },
                dns: {
                    type: "object",
                    description: "DNS options",
                    required: [ "provider" ],
                    properties: {
                        upstreams: {
                            type: "array",
                            description: "Upstream DNS servers",
                            items: {
                                type: "string",
                                title: "upstream",
                                description: "Upstream DNS",
                                pattern: "^[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+$",
                            },
                        },
                        provider: {
                            type: "object",
                            description: "DNS Provider",
                            required: [ "name", "email", "api" ],
                            properties: {
                                name: {
                                    type: "string",
                                    description: "DNS Provider code",
                                },
                                email: {
                                    type: "string",
                                    description: "Email address used for registration",
                                    pattern: "^[A-Za-z0-9]+@[A-Za-z0-9]+$",
                                },
                                api: {
                                    type: "array",
                                    description: "DNS Provider variables",
                                    items: {
                                        type: "object",
                                        title: "variable",
                                        description: "DNS Provider variable",
                                        required: [ "name", "value" ],
                                        properties: {
                                            name: {
                                                type: "string",
                                                description: "Variable name",
                                            },
                                            value: {
                                                type: "string",
                                                description: "Variable value",
                                            },
                                        },
                                    },
                                },
                            },
                        },
                    },
                },
                smtp: {
                    type: "object",
                    description: "SMTP options",
                    required: [ "host", "port", "username", "password", "sender" ],
                    properties: {
                        host: {
                            type: "string",
                            description: "Server hostname",
                        },
                        port: {
                            type: "integer",
                            description: "Server port number",
                            minimum: 1,
                            maximum: 65535,
                        },
                        username: {
                            type: "string",
                            description: "Email address or username",
                        },
                        password: {
                            type: "string",
                            description: "Password",
                        },
                        sender: {
                            type: "string",
                            description: "Send emails as",
                        },
                    },
                },
            },
        },
    },
};
