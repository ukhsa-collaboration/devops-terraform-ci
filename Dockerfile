# Use a specific version of the base image to ensure builds are reproducible
FROM python:3.12-slim-bookworm as builder

# Use environment variables for versions, making updates easier
ENV CHECKOV_VERSION="3.2.125"
ENV TERRAFORM_VERSION="1.8.4"
ENV TFENV_VERSION="3.0.0"
ENV TFLINT_VERSION="0.51.1"
ENV TFDOCS_VERSION="0.18.0"
ENV TFLINT_AWS_PLUGIN_VERSION="0.32.0"
ENV TFLINT_AZURERM_PLUGIN_VERSION="0.26.0"

# Set the working directory to /tmp
WORKDIR /tmp

# Update the package lists for upgrades and new packages, install desired packages, and clean up
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        wget \
        unzip \
        curl \
        gnupg \
        ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Upgrade pip and install Checkov
RUN pip3 install --no-cache-dir --upgrade pip && \
    pip3 install --no-cache-dir checkov==${CHECKOV_VERSION}

# Install tfenv to manage Terraform versions
RUN wget -O tfenv.zip https://github.com/tfutils/tfenv/archive/refs/tags/v${TFENV_VERSION}.zip && \
    unzip tfenv.zip -d $HOME/.tfenv && \
    rm tfenv.zip && \
    ln -s /root/.tfenv/tfenv-${TFENV_VERSION}/bin/* /usr/local/bin && \
    echo "v${TERRAFORM_VERSION}" > /root/.tfenv/tfenv-${TFENV_VERSION}/version && \
    echo "trust-tfenv: yes" > /root/.tfenv/tfenv-${TFENV_VERSION}/use-gpgv && \
    tfenv use ${TERRAFORM_VERSION}

# TFlint
RUN wget -O tflint.zip "https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_amd64.zip" && \
    unzip tflint.zip -d /usr/local/bin && \
    rm tflint.zip

# Copy the .tflint.hcl configuration file
COPY .tflint.hcl /root/.tflint.hcl

# TFDocs
RUN wget -O terraform-docs.tar.gz "https://terraform-docs.io/dl/v${TFDOCS_VERSION}/terraform-docs-v${TFDOCS_VERSION}-linux-amd64.tar.gz" && \
    mkdir terraform-docs && \
    tar -xzf terraform-docs.tar.gz -C terraform-docs && \
    chmod +x terraform-docs/terraform-docs && \
    mv terraform-docs/terraform-docs /usr/local/bin/terraform-docs && \
    rm terraform-docs.tar.gz && \
    rm -rf terraform-docs

# Initialize TFLint with the specified plugins
RUN tflint --init

# Use a slim image for the final image
FROM python:3.12-slim-bookworm

# Applications required just for tools
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        unzip \
        git \
        curl && \
    rm -rf /var/lib/apt/lists/*

# Copy the installed binaries from the builder image
COPY --from=builder /usr/local /usr/local

# Copy the TFLint plugin configuration from the builder image
COPY --from=builder /root/.tflint.hcl /root/.tflint.hcl 
COPY --from=builder /root/.tflint.d /root/.tflint.d

# Setup tfenv from the builder image
COPY --from=builder /root/.tfenv /root/.tfenv

CMD [ "bash" ]
