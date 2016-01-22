COOKBOOK_ROOT=../..
BERKS_DIR=$(COOKBOOK_ROOT)/berks-cookbooks
BERKS_LOCK=$(COOKBOOK_ROOT)/Berksfile.lock
BERKS_LOCATION=$(COOKBOOK_ROOT)/Berksfile
TIMESTAMP_FILE=upload.txt

all: berksy

$(BERKS_LOCK): $(BERKS_LOCATION) $(COOKBOOK_ROOT)/attributes/* $(COOKBOOK_ROOT)/recipes/* $(COOKBOOK_ROOT)/metadata.rb
	berks install -b $(BERKS_LOCATION)

berksy: $(BERKS_DIR)

$(BERKS_DIR): $(BERKS_LOCK)
	rm -rf $(BERKS_DIR)
	berks vendor -b $(BERKS_LOCATION) $(BERKS_DIR)



upload: $(TIMESTAMP_FILE)

$(TIMESTAMP_FILE): $(BERKS_DIR)
	knife cookbook upload -o $(BERKS_DIR) --all
	touch $(TIMESTAMP_FILE)