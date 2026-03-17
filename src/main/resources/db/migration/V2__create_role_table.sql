CREATE TABLE roles
(
    name        VARCHAR(50) PRIMARY KEY,
    description VARCHAR(255)
);

CREATE TABLE permissions
(
    name        VARCHAR(50) PRIMARY KEY,
    description VARCHAR(255)
);

CREATE TABLE role_permissions
(
    role_name       VARCHAR(50),
    permission_name VARCHAR(50),
    PRIMARY KEY (role_name, permission_name),
    FOREIGN KEY (role_name) REFERENCES roles (name) ON DELETE CASCADE,
    FOREIGN KEY (permission_name) REFERENCES permissions (name) ON DELETE CASCADE
);