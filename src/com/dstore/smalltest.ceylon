
shared class NotificationProxy(listener) {
	Anything () listener;
}

void addToChangeList(TestClass x) {
	
}

shared class TestClass() {
	
	
	late NotificationProxy blubb;
	
	void postInit() {
		blubb = NotificationProxy {
			void listener() {
				addToChangeList(this);
			}
		};
	}
	
	void run() {
		print("Running");
		TestClass().postInit();
	}
}