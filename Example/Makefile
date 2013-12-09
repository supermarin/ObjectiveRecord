PROJECT_NAME=SampleProject
WORKSPACE=$(PROJECT_NAME).xcworkspace
DEFAULT_SCHEME=$(PROJECT_NAME)
DEFAULT_FLAGS=-sdk iphonesimulator

DEFAULT_TASK=$(TESTING_TOOL) -workspace $(WORKSPACE) -scheme $(DEFAULT_SCHEME) $(DEFAULT_FLAGS)

clean:
	$(DEFAULT_TASK) clean

test:
	$(DEFAULT_TASK) test | xcpretty -c

install_pods:
	pod install

update_tools:
	gem install cocoapods
	gem install xcpretty

ci: update_tools install_pods test

