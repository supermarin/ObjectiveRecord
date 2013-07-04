PROJECT_NAME=SampleProject
WORKSPACE=$(PROJECT_NAME).xcworkspace
DEFAULT_SCHEME=$(PROJECT_NAME)
TESTING_TOOL=xcodebuild
#TESTING_TOOL=xctool

test:
	$(TESTING_TOOL) -workspace $(WORKSPACE) -scheme $(DEFAULT_SCHEME) clean test

install_pods:
	pod install

update_tools:
	gem update cocoapods

ci: update_tools install_pods test

