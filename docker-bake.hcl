variable "TAG" {
    default = "latest"
}

variable "PHP_VERSION" {
    default = "8.1"
}

group "default" {
    targets = [
        "pandawa-swoole",
    ]
}

target "pandawa-swoole" {
    target = "pandawa-swoole"
    args = {
        PHP_VERSION = "${PHP_VERSION}"
    }
    tags = [
        "pandawa/pandawa:${TAG}-swoole-php${PHP_VERSION}",
        "pandawa/pandawa:latest"
    ]
    platforms = [
        "linux/amd64",
        "linux/arm64"
    ]
}
