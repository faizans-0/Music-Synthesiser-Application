classdef MusicSynthesiser < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure               matlab.ui.Figure
        GridLayout             matlab.ui.container.GridLayout
        LeftPanel              matlab.ui.container.Panel
        ListOfNotesListBox     matlab.ui.control.ListBox
        SelectthenoteyouwanttoplayLabel  matlab.ui.control.Label
        CenterPanel            matlab.ui.container.Panel
        UIAxes2                matlab.ui.control.UIAxes
        UIAxes                 matlab.ui.control.UIAxes
        RightPanel             matlab.ui.container.Panel
        LoudnessSlider         matlab.ui.control.Slider
        LoudnessSliderLabel    matlab.ui.control.Label
        DurationSliderLabel_2  matlab.ui.control.Label
        DurationSlider         matlab.ui.control.Slider
        DurationSliderLabel    matlab.ui.control.Label
        AddButton              matlab.ui.control.Button
        EditField              matlab.ui.control.EditField
        EnterANameLabel        matlab.ui.control.Label
        ExportButton           matlab.ui.control.Button
        ClearButton            matlab.ui.control.Button
        PlayButton             matlab.ui.control.Button
    end

    % Properties that correspond to apps with auto-reflow
    properties (Access = private)
        onePanelWidth = 576;
        twoPanelWidth = 768;
    end

    
    properties (Access = private)

        % Variables that are used in more than one GUI Componenets

        sec                 % Duration of the note
        freq                % Frequency of the note
        loud                % Loudness or amplitude of the note
        song                % Audible note using frequency, duration and louudness
        songname = ""       % Name of the music file when exporting
        Fs = 48000          % Sample Rate (Number of points in a second)
        freqlist = []       % Array of all the frequencies
        seclist = []        % Array of all the durations
        loudlist = []       % Array of all the loudnesses
        songlist = []       % Array of the complete song
    end
    
    methods (Access = private)
        
        % Function to take the frequency, duration and amplitude and make it
        % conver it into an audible tone

        function msc = MusicFreq(~, freq2, sec2, loud2)
            msc = loud2*sin(linspace(0, sec2*freq2*2*pi, round(sec2*48000)));     % Formula that creates a sine wave using the 3 inputs
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Value changed function: ListOfNotesListBox
        function ListOfNotesListBoxValueChanged(app, event)
            value = app.ListOfNotesListBox.Value;   % Obtains value from the listbox
            app.freq = str2double(value);           % Converts the string value otained from the listbox to double and stores it
        end

        % Value changed function: DurationSlider
        function DurationSliderValueChanged(app, event)
            value = app.DurationSlider.Value;       % Obtaines value from the duration slider
            app.sec = value;                        % Stores it
        end

        % Value changed function: LoudnessSlider
        function LoudnessSliderValueChanged(app, event)
            value = app.LoudnessSlider.Value;       % Obtains value from the loudness slider
            app.loud = value;                       % Stores it
        end

        % Button pushed function: AddButton
        function AddButtonPushed(app, event)
            if app.sec == 0                                                 % Checks if the value of duration is 0
                errordlg("Duration Can Not Be 0", "Duration Error");        % Shows an error message if it is                              

            else                                                            % If the value isn't 0
                app.freqlist = [app.freqlist app.freq];                     % Adds the frequency to the frequency array
                app.seclist = [app.seclist app.sec];                        % Addds the duration to the duration array
                app.loudlist = [app.loudlist app.loud];                     % Adds the loudness to the loudness array

                if isempty(app.freqlist)                                    % Checks if the frequency list is empty (If no note is selected in the gui)
                    errordlg("Please Select A Note", "Selection Error");    % Shows an error message
                    app.seclist = [];                                       % Emptys the other lists
                    app.loudlist = [];

                elseif isempty(app.seclist)                                 % Checks if the duration list is empty (This happens if the slider isn't moved)
                    errordlg("Duration Can Not Be 0", "Duration Error");    % Shows an error message
                    app.freqlist = [];                                      % Emptys the other lists
                    app.loudlist = [];

                elseif isempty(app.loudlist)                                % Checks if the loudness list is empty (This also happens if the slider isnt moved)
                errordlg("Please Select A Loudness", "Loudness Error");     % Shows an error message
                app.freqlist = [];                                          % Emptys the other lists
                app.seclist = [];

                else                                                        % If no problems
                    app.song = MusicFreq(app, app.freq, app.sec, app.loud); % Converts the the 3 inputs to an audible tone or a sine wave
                    app.songlist = [app.songlist app.song];                 % Adds it to the song list

                    sp = 0;                                                                     % Variable for start point
                    ep = 0;                                                                     % Variable for end point

                    for n = 1 : length(app.freqlist)                                            % Runs a loop for each item in the frequency list
                        ep = ep + app.seclist(n);                                               % Sets the end point to the first frequency's duration
                        xplot = (sp : 1/app.Fs : ep);                                           % Creats an array with 1/sample rate between start and end
                        yplot = repmat(app.freqlist(n), length(xplot), 1);                      % Creates a new matrix with one coulumn for a frequency and as many rows as the length of the array xplot
                        hold(app.UIAxes, "on");                                                 % Makes it so that the previous plot isn't erased
                        plot(app.UIAxes, xplot, yplot, "Color", "#1A006B", "LineWidth", 10);    % Plots the xplot and yplot with hex code for colour and 10 point width
                        ylim(app.UIAxes, [400 800]);                                            % Sets the limits of yaxis between 400 and 800
                        sp = sp + app.seclist(n);                                               % Sets the new startpoint as the previous endpoint for the next plot
                    end

                    x = (length(app.songlist))/app.Fs;                                                  % Divides the sinewave by the sample rate
                    len = length(app.songlist);                                                         % length of the song list
                    xplot2 = linspace(0, x, len);                                                       % Creates an array of as many evenly spaced points between 0 and x as the length of the song list
                    plot (app.UIAxes2, xplot2, app.songlist, "Color", "#0000B2", "LineWidth", 0.1);     % Plots this new array and the songlist with hex code for colour and linewidth as 0.1
                    ylim(app.UIAxes2, [-1 1]);                                                          % Sets the limits for the y axis between -1 and 1

                end
            end
        end

        % Button pushed function: PlayButton
        function PlayButtonPushed(app, event)
            sound(app.songlist, app.Fs);            % Plays the complete music stored in the song list with the sample rate as Fs
        end

        % Value changed function: EditField
        function EditFieldValueChanged(app, event)
            value = app.EditField.Value;            % Gets input from the text box
            app.songname = value;                   % Variable to store the value
        end

        % Button pushed function: ExportButton
        function ExportButtonPushed(app, event)
            if app.songname == ""                                       % Checks if the input text box for song name is empty     
                errordlg("Please Enter A Name", "Naming Error");        % Shows an error message if it is
            else                                                        
                filename = app.songname + ".wav";                       % String with file type added to the song name
                exportsong = questdlg("The Song Will Be Saved With The Name: "+filename, "Export Song", "Confirm", "Cancel", "Confirm");    % Confirmation prompt for the name

                if exportsong == "Confirm"          % If the name is confirmed          
                    export = 1;                     % Variable for the song to be exported

                    if isfile(filename)             % Checks if a file with the same name already exists
                        existsong = questdlg("A File With The Same Name Already Exists. Do You Want To Replace It?", "Duplicate File", "Replace", "Cancel", "Replace");     % Confirmation to replace the old file with the new one
                        
                        if existsong == "Replace"       % If the file is to be replaced
                            export = 1;                 % The song is to be exported
                        else                            % If not
                            export = 0;                 % The song is not to be exported
                        end
                    end

                    if export == 1                                          % Checks if the song is to be exported or not
                        audiowrite(filename, app.songlist, app.Fs);         % Expots the song and saves it
                        msgbox("The Song Has Been Successfully Exported");  % Message saying it was a success
                    end
                end
            end
        end

        % Button pushed function: ClearButton
        function ClearButtonPushed(app, event)
            clearsong = questdlg("Are You Sure You Want To Clear The Song?", "Clear Song", "Yes", "No", "Yes");     % Prompt to confirm clear or not
            if clearsong=="Yes"                                                                                     % If Yes
                app.freqlist = [];                                                                                  % Clears all the lists
                app.seclist = [];
                app.loudlist = [];
                app.songlist = [];
                cla(app.UIAxes);                                                                                    % Clears both the first graph
                cla(app.UIAxes2);                                                                                   % Clears the second graph
                app.songname = "";                                                                                  % Clears the song name
                app.EditField.Value = "";                                                                           % Empties the text box
            end
        end

        % Changes arrangement of the app based on UIFigure width
        function updateAppLayout(app, event)
            currentFigureWidth = app.UIFigure.Position(3);
            if(currentFigureWidth <= app.onePanelWidth)
                % Change to a 3x1 grid
                app.GridLayout.RowHeight = {480, 480, 480};
                app.GridLayout.ColumnWidth = {'1x'};
                app.CenterPanel.Layout.Row = 1;
                app.CenterPanel.Layout.Column = 1;
                app.LeftPanel.Layout.Row = 2;
                app.LeftPanel.Layout.Column = 1;
                app.RightPanel.Layout.Row = 3;
                app.RightPanel.Layout.Column = 1;
            elseif (currentFigureWidth > app.onePanelWidth && currentFigureWidth <= app.twoPanelWidth)
                % Change to a 2x2 grid
                app.GridLayout.RowHeight = {480, 480};
                app.GridLayout.ColumnWidth = {'1x', '1x'};
                app.CenterPanel.Layout.Row = 1;
                app.CenterPanel.Layout.Column = [1,2];
                app.LeftPanel.Layout.Row = 2;
                app.LeftPanel.Layout.Column = 1;
                app.RightPanel.Layout.Row = 2;
                app.RightPanel.Layout.Column = 2;
            else
                % Change to a 1x3 grid
                app.GridLayout.RowHeight = {'1x'};
                app.GridLayout.ColumnWidth = {253, '1x', 270};
                app.LeftPanel.Layout.Row = 1;
                app.LeftPanel.Layout.Column = 1;
                app.CenterPanel.Layout.Row = 1;
                app.CenterPanel.Layout.Column = 2;
                app.RightPanel.Layout.Row = 1;
                app.RightPanel.Layout.Column = 3;
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.Color = [0 1 1];
            app.UIFigure.Position = [100 100 943 480];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @updateAppLayout, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {253, '1x', 270};
            app.GridLayout.RowHeight = {'1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.Scrollable = 'on';

            % Create LeftPanel
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;

            % Create SelectthenoteyouwanttoplayLabel
            app.SelectthenoteyouwanttoplayLabel = uilabel(app.LeftPanel);
            app.SelectthenoteyouwanttoplayLabel.HorizontalAlignment = 'right';
            app.SelectthenoteyouwanttoplayLabel.FontName = 'Leelawadee';
            app.SelectthenoteyouwanttoplayLabel.FontSize = 16;
            app.SelectthenoteyouwanttoplayLabel.Position = [82 371 92 45];
            app.SelectthenoteyouwanttoplayLabel.Text = 'List Of Notes';

            % Create ListOfNotesListBox
            app.ListOfNotesListBox = uilistbox(app.LeftPanel);
            app.ListOfNotesListBox.Items = {'A Flat', 'A', 'B Flat', 'B', 'C', 'C Sharp', 'D', 'D Sharp', 'E', 'F', 'F Sharp', 'G'};
            app.ListOfNotesListBox.ItemsData = {'415', '440', '466', '494', '523', '554', '587', '622', '659', '698', '740', '784'};
            app.ListOfNotesListBox.ValueChangedFcn = createCallbackFcn(app, @ListOfNotesListBoxValueChanged, true);
            app.ListOfNotesListBox.FontName = 'Consolas';
            app.ListOfNotesListBox.FontSize = 15;
            app.ListOfNotesListBox.Position = [37 81 181 291];
            app.ListOfNotesListBox.Value = {};

            % Create CenterPanel
            app.CenterPanel = uipanel(app.GridLayout);
            app.CenterPanel.Layout.Row = 1;
            app.CenterPanel.Layout.Column = 2;

            % Create UIAxes
            app.UIAxes = uiaxes(app.CenterPanel);
            title(app.UIAxes, 'Frequency Vs Time Graph')
            xlabel(app.UIAxes, 'Time (s)')
            ylabel(app.UIAxes, 'Frequency (Hz)')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.Position = [60 256 300 185];

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.CenterPanel);
            title(app.UIAxes2, 'Amplitude Vs Time Graph')
            xlabel(app.UIAxes2, 'Time (s)')
            ylabel(app.UIAxes2, 'Amplitude')
            zlabel(app.UIAxes2, 'Z')
            app.UIAxes2.Position = [60 33 300 185];

            % Create RightPanel
            app.RightPanel = uipanel(app.GridLayout);
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 3;

            % Create PlayButton
            app.PlayButton = uibutton(app.RightPanel, 'push');
            app.PlayButton.ButtonPushedFcn = createCallbackFcn(app, @PlayButtonPushed, true);
            app.PlayButton.Position = [83 217 100 22];
            app.PlayButton.Text = 'Play';

            % Create ClearButton
            app.ClearButton = uibutton(app.RightPanel, 'push');
            app.ClearButton.ButtonPushedFcn = createCallbackFcn(app, @ClearButtonPushed, true);
            app.ClearButton.Position = [85 60 100 22];
            app.ClearButton.Text = 'Clear';

            % Create ExportButton
            app.ExportButton = uibutton(app.RightPanel, 'push');
            app.ExportButton.ButtonPushedFcn = createCallbackFcn(app, @ExportButtonPushed, true);
            app.ExportButton.Position = [85 102 100 22];
            app.ExportButton.Text = 'Export';

            % Create EnterANameLabel
            app.EnterANameLabel = uilabel(app.RightPanel);
            app.EnterANameLabel.HorizontalAlignment = 'right';
            app.EnterANameLabel.Position = [91 176 83 22];
            app.EnterANameLabel.Text = 'Enter A Name:';

            % Create EditField
            app.EditField = uieditfield(app.RightPanel, 'text');
            app.EditField.ValueChangedFcn = createCallbackFcn(app, @EditFieldValueChanged, true);
            app.EditField.Position = [86 144 100 22];

            % Create AddButton
            app.AddButton = uibutton(app.RightPanel, 'push');
            app.AddButton.ButtonPushedFcn = createCallbackFcn(app, @AddButtonPushed, true);
            app.AddButton.Position = [83 256 100 22];
            app.AddButton.Text = 'Add';

            % Create DurationSliderLabel
            app.DurationSliderLabel = uilabel(app.RightPanel);
            app.DurationSliderLabel.HorizontalAlignment = 'right';
            app.DurationSliderLabel.Position = [27 394 51 22];
            app.DurationSliderLabel.Text = 'Duration';

            % Create DurationSlider
            app.DurationSlider = uislider(app.RightPanel);
            app.DurationSlider.Limits = [0 5];
            app.DurationSlider.MajorTicks = [0 1 2 3 4 5];
            app.DurationSlider.MajorTickLabels = {'0', '1', '2', '3', '4', '5'};
            app.DurationSlider.ValueChangedFcn = createCallbackFcn(app, @DurationSliderValueChanged, true);
            app.DurationSlider.Position = [90 403 150 3];

            % Create DurationSliderLabel_2
            app.DurationSliderLabel_2 = uilabel(app.RightPanel);
            app.DurationSliderLabel_2.HorizontalAlignment = 'right';
            app.DurationSliderLabel_2.Position = [38 373 32 22];
            app.DurationSliderLabel_2.Text = '(sec)';

            % Create LoudnessSliderLabel
            app.LoudnessSliderLabel = uilabel(app.RightPanel);
            app.LoudnessSliderLabel.HorizontalAlignment = 'right';
            app.LoudnessSliderLabel.Position = [12 332 58 22];
            app.LoudnessSliderLabel.Text = 'Loudness';

            % Create LoudnessSlider
            app.LoudnessSlider = uislider(app.RightPanel);
            app.LoudnessSlider.Limits = [0 1];
            app.LoudnessSlider.ValueChangedFcn = createCallbackFcn(app, @LoudnessSliderValueChanged, true);
            app.LoudnessSlider.Position = [91 341 150 3];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = MusicSynthesiser

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end