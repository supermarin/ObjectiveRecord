PROJECT_NAME=SampleProject
WORKSPACE=$(PROJECT_NAME).xcworkspace
DEFAULT_SCHEME=$(PROJECT_NAME)
#TESTING_TOOL=xctool
TESTING_TOOL=xcodebuild

clean:
	$(TESTING_TOOL) -workspace $(WORKSPACE) -scheme $(DEFAULT_SCHEME) \
		-sdk iphonesimulator ONLY_ACTIVE_ARCH=NO clean
test:
	$(TESTING_TOOL) -workspace $(WORKSPACE) -scheme $(DEFAULT_SCHEME) \
		-sdk iphonesimulator ONLY_ACTIVE_ARCH=NO test

install_pods:
	pod install

update_tools:
	gem update cocoapods

ci: update_tools install_pods clean test

