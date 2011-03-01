import com.pentagram.model.vo.Note;
import com.pentagram.model.vo.User;

private function handleLogout(event:AppEvent):void {
	model.user = null;
	view.currentState = view.loggedOutState.name;
}
private function handleLogin(event:AppEvent):void {
	model.user = event.args[0] as User;
	model.exportMenuItem.enabled = true;
	model.importMenuItem.enabled = true;
	view.currentState = view.loggedInState.name;
}
private function handleLoadSearchView(event:VisualizerEvent):void {
	view.client = null;
	view.clientBar.infoBtn.selected = false;
	view.clientBar.currentState = view.clientBar.closedState.name;
}
private function handleImportFailed(event:EditorEvent):void {
	view.errorPanel.includeCancel = false;
	view.errorPanel.errorMessage = event.args[0];
}
private function handleImport(event:Event):void {
	this.eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.RESUME_IMPORT,event.type));
}
private function handleStartImport(event:Event):void {
	view.importPanel.errorMessage ="Is this dataset over time?";
}
private function handleNotification(event:EditorEvent):void {
	view.errorPanel.includeCancel = true;
	currentEvent = event.args[1];
	view.errorPanel.errorMessage = event.args[0];
}
private function handleOkError(event:Event):void {
	if(currentEvent && view.errorPanel.includeCancel) {
		this.eventDispatcher.dispatchEvent(currentEvent);
		currentEvent = null;
	}
}
private function handleFullScreen(event:Event):void{
	view.currentVisualizer.updateSize();
}
private function handleExportSettingsSave(event:MouseEvent):void {
	view.exportPanel.visible = false;
}
private function handleIncludeTools(event:Event):void {
	model.includeTools = view.exportPanel.includeTools.selected;
}
private function selectedNewDirectory(event:MouseEvent):void {
	model.exportDirectory = new File();
	model.exportDirectory.addEventListener(Event.SELECT, file_select);
	model.exportDirectory.browseForDirectory("Please select a directory...")
}
private function file_select(evt:Event):void {
	view.exportPanel.dirPath.text = model.exportDirectory.nativePath;
}
private function handleInfoChanged(event:MouseEvent):void {
	var note:Note
	if(model.client.notes.length == 1) {
		note = model.client.notes.getItemAt(0) as Note;
		note.description = view.infoText.text;
		eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.UPDATE_NOTE,note));
	}
	else {
		note = new Note();
		note.description = view.infoText.text;
		note.clientid = model.client.id;
		note.datasets = datasetids;
		eventDispatcher.dispatchEvent(new EditorEvent(EditorEvent.CREATE_NOTE,note));
	}
}
private function findNoteByDatasets(note:Note):Boolean {
	return note.datasets == datasetids;
}
private function checkNotes():void {
	model.client.notes.refresh();
	if(model.client.notes.length  == 1) {
		view.infoText.text = Note(model.client.notes.getItemAt(0)).description;	
	}
	else
		view.infoText.text = '';		
}