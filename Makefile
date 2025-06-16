SELF  := $(patsubst %/,%,$(dir $(abspath $(firstword $(MAKEFILE_LIST)))))

ENV_RUN      = hatch env run -e $(1) --
ENV_CSP_DEFAULT := $(shell hatch env find cloud-provider-default)

ifdef ENV_CSP_DEFAULT
$(ENV_CSP_DEFAULT):
	hatch env create cloud-provider-default
endif

.PHONY: submodule-requirements main verification cloud-provider

submodule-requirements:
	$(MAKE) -C submodule-one-deploy-validation requirements

# Explicitly expose these targets to the parent Makefile.
main verification:
	$(MAKE) -C submodule-one-deploy-validation I=$(SELF)/inventory/cloud-provider.yml $@

specifics: $(ENV_CSP_DEFAULT)
	cd $(SELF)/ && \
	$(call ENV_RUN,cloud-provider-default) ansible-playbook $(SELF)/playbooks/cloud-provider.yml
