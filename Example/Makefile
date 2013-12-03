PROJECT_NAME=SampleProject
WORKSPACE=$(PROJECT_NAME).xcworkspace
DEFAULT_SCHEME=$(PROJECT_NAME)
TESTING_TOOL=xcodebuild

clean:
	$(TESTING_TOOL) -workspace $(WORKSPACE) -scheme $(DEFAULT_SCHEME) \
		-sdk iphonesimulator clean
test:
	$(TESTING_TOOL) -workspace $(WORKSPACE) -scheme $(DEFAULT_SCHEME) \
		-sdk iphonesimulator test

install_pods:
	pod install

update_tools:
	brew update
	brew upgrade xctool
	gem install cocoapods

ci: update_tools install_pods clean test

