# Use a specific version of the base image to ensure builds are reproducible
FROM python:3.12-slim-bookworm

# Use environment variables for versions, making updates easier
ENV TERRAFORM_VERSION="1.8.4"
ENV TFENV_VERSION="3.0.0"
ENV TFLINT_VERSION="0.51.1"
ENV TFDOCS_VERSION="0.18.0"
ENV CHECKOV_VERSION="3.2.125"

# Update the package lists for upgrades and new packages, install desired packages, and clean up
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        wget \
        unzip \
        curl \
        gnupg \
        ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Upgrade pip to ensure the latest version is used
RUN pip3 install --upgrade pip

# Install tfenv to manage Terraform versions
RUN wget -O /tmp/tfenv.zip https://github.com/tfutils/tfenv/archive/refs/tags/v${TFENV_VERSION}.zip && \
    unzip /tmp/tfenv.zip -d $HOME/.tfenv && \
    ln -s $HOME/.tfenv/tfenv-${TFENV_VERSION}/bin/* /usr/local/bin && \
    echo "v${TERRAFORM_VERSION}" > $HOME/.tfenv/tfenv-${TFENV_VERSION}/version && \
    echo "trust-tfenv: yes" > $HOME/.tfenv/tfenv-${TFENV_VERSION}/use-gpgv

# TFlint
RUN wget -O /tmp/tflint.zip "https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_amd64.zip" && \
    unzip /tmp/tflint.zip -d /usr/local/bin && \
    rm /tmp/tflint.zip

# TFDocs
RUN wget -O /tmp/terraform-docs.tar.gz "https://terraform-docs.io/dl/v${TFDOCS_VERSION}/terraform-docs-v${TFDOCS_VERSION}-linux-amd64.tar.gz" && \
    mkdir /tmp/terraform-docs && \
    tar -xzf /tmp/terraform-docs.tar.gz -C /tmp/terraform-docs && \
    chmod +x /tmp/terraform-docs/terraform-docs && \
    mv /tmp/terraform-docs/terraform-docs /usr/local/bin/terraform-docs && \
    rm /tmp/terraform-docs.tar.gz && \
    rm -rf /tmp/terraform-docs

# Checkov
RUN pip3 install checkov==${CHECKOV_VERSION}

CMD [ "bash" ]
