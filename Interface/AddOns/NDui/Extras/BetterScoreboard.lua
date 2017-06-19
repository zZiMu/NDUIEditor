﻿function format_thousand(v)
	if v >= 1e8 then
		return ("%.2f亿"):format(v / 1e8)
	elseif v >= 1e4 then
		return ("%.1f万"):format(v / 1e4)
	else
		return ("%.0f"):format(v)
	end
end

-- updated from  https://github.com/tekkub/wow-ui-source/blob/live/FrameXML/WorldStateFrame.lua
function WorldStateScoreFrame_Update()
	local isArena, isRegistered = IsActiveBattlefieldArena();
	local isRatedBG = IsRatedBattleground();
	local isWargame = IsWargame();
	local isSkirmish = IsArenaSkirmish();
	local battlefieldWinner = GetBattlefieldWinner();

	local firstFrameAfterCustomStats = WorldStateScoreFrameHonorGained;

	WorldStateScoreFramePrestige:SetShown(UnitLevel("player") == MAX_PLAYER_LEVEL_TABLE[LE_EXPANSION_LEVEL_CURRENT]);

	if ( isArena ) then
		-- Hide unused tabs
		WorldStateScoreFrameTab1:Hide();
		WorldStateScoreFrameTab2:Hide();
		WorldStateScoreFrameTab3:Hide();

		-- Hide unused columns
		WorldStateScoreFrameDeaths:Hide();
		WorldStateScoreFrameHK:Hide();
		WorldStateScoreFrameHonorGained:Hide();
		WorldStateScoreFrameBgRating:Hide();

		if ( isWargame or isSkirmish ) then
			WorldStateScoreFrameRatingChange:Hide()
		end
		WorldStateScoreFrameName:SetWidth(325)

		-- Reanchor some columns.
		WorldStateScoreFrameDamageDone:SetPoint("LEFT", WorldStateScoreFrameKB, "RIGHT", -5, 0);
		WorldStateScoreFrameTeam:Hide();
		if ( not isWargame and not isSkirmish ) then
			WorldStateScoreFrameRatingChange:Show();
			WorldStateScoreFrameRatingChange:SetPoint("LEFT", WorldStateScoreFrameHealingDone, "RIGHT", 0, 0);
			WorldStateScoreFrameRatingChange.sortType = "bgratingChange";
		end
		WorldStateScoreFrameMatchmakingRating:Hide();
		WorldStateScoreFrameKB:SetPoint("LEFT", WorldStateScoreFrameName, "RIGHT", 4, 0);
	else
		-- Show Tabs
		WorldStateScoreFrameTab1:Show();
		WorldStateScoreFrameTab2:Show();
		WorldStateScoreFrameTab3:Show();

		WorldStateScoreFrameTeam:Hide();
		WorldStateScoreFrameDeaths:Show();

		WorldStateScoreFrameName:SetWidth(175)

		-- Reanchor some columns.
		WorldStateScoreFrameKB:SetPoint("LEFT", WorldStateScoreFrameName, "RIGHT", 4, 0);

		if isRatedBG then
			WorldStateScoreFrameHonorGained:Hide();
			WorldStateScoreFrameHK:Hide();
			WorldStateScoreFrameDamageDone:SetPoint("LEFT", WorldStateScoreFrameDeaths, "RIGHT", -5, 0);

			WorldStateScoreFrameBgRating:Show();
			firstFrameAfterCustomStats = WorldStateScoreFrameBgRating;

			if battlefieldWinner then
				WorldStateScoreFrameRatingChange.sortType = "bgratingChange";
				WorldStateScoreFrameRatingChange:SetPoint("LEFT", WorldStateScoreFrameBgRating, "RIGHT", -5, 0);
				WorldStateScoreFrameRatingChange:Show();
			else
				WorldStateScoreFrameRatingChange:Hide();
			end
		else
			WorldStateScoreFrameHK:Show();
			WorldStateScoreFrameHK:SetPoint("LEFT", WorldStateScoreFrameDeaths, "RIGHT", -5, 0);
			WorldStateScoreFrameDamageDone:SetPoint("LEFT", WorldStateScoreFrameHK, "RIGHT", -5, 0);

			WorldStateScoreFrameHonorGained:Show();

			WorldStateScoreFrameRatingChange:Hide();
			WorldStateScoreFrameBgRating:Hide();
		end
		WorldStateScoreFrameMatchmakingRating:Hide();
	end

	--Show the frame if its hidden and there is a victor
	if ( battlefieldWinner ) then
		-- Show the final score frame, set textures etc.

		if  not WorldStateScoreFrame.firstOpen then
			ShowUIPanel(WorldStateScoreFrame);
			WorldStateScoreFrame.firstOpen = true;
		end

		if ( isArena ) then
			WorldStateScoreFrameLeaveButton:SetText(LEAVE_ARENA);
			WorldStateScoreFrameTimerLabel:SetText(TIME_TO_PORT_ARENA);
		else
			WorldStateScoreFrameLeaveButton:SetText(LEAVE_BATTLEGROUND);
			WorldStateScoreFrameTimerLabel:SetText(TIME_TO_PORT);
		end

		WorldStateScoreFrameLeaveButton:Show();
		WorldStateScoreFrameTimerLabel:Show();
		WorldStateScoreFrameTimer:Show();

		if (isSkirmish)then
			WorldStateScoreFrameQueueButton:Show();
			WorldStateScoreFrameLeaveButton:SetPoint("BOTTOM", WorldStateScoreFrameLeaveButton:GetParent(), "BOTTOM", 80, 3);
		else
			WorldStateScoreFrameQueueButton:Hide();
			WorldStateScoreFrameLeaveButton:SetPoint("BOTTOM", WorldStateScoreFrameLeaveButton:GetParent(), "BOTTOM", 0, 3);
		end

		-- Show winner
		if ( isArena ) then
			if ( isRegistered ) then
				if ( GetBattlefieldTeamInfo(battlefieldWinner) ) then
					local teamName
					if ( battlefieldWinner == 0) then
						teamName = ARENA_TEAM_NAME_GREEN
					else
						teamName = ARENA_TEAM_NAME_GOLD
					end
					WorldStateScoreWinnerFrameText:SetFormattedText(VICTORY_TEXT_ARENA_WINS, teamName);
				else
					WorldStateScoreWinnerFrameText:SetText(VICTORY_TEXT_ARENA_DRAW);
				end
			else
				WorldStateScoreWinnerFrameText:SetText(_G["VICTORY_TEXT_ARENA"..battlefieldWinner]);
			end
			if ( battlefieldWinner == 0 ) then
				-- Green Team won
				WorldStateScoreWinnerFrameLeft:SetVertexColor(0.19, 0.57, 0.11);
				WorldStateScoreWinnerFrameRight:SetVertexColor(0.19, 0.57, 0.11);
				WorldStateScoreWinnerFrameText:SetVertexColor(0.1, 1.0, 0.1);
			else
				-- Gold Team won
				WorldStateScoreWinnerFrameLeft:SetVertexColor(0.85, 0.71, 0.26);
				WorldStateScoreWinnerFrameRight:SetVertexColor(0.85, 0.71, 0.26);
				WorldStateScoreWinnerFrameText:SetVertexColor(1, 0.82, 0);
			end
		else
			WorldStateScoreWinnerFrameText:SetText(_G["VICTORY_TEXT"..battlefieldWinner]);
			if ( battlefieldWinner == 0 ) then
				-- Horde won
				WorldStateScoreWinnerFrameLeft:SetVertexColor(0.52, 0.075, 0.18);
				WorldStateScoreWinnerFrameRight:SetVertexColor(0.5, 0.075, 0.18);
				WorldStateScoreWinnerFrameText:SetVertexColor(1.0, 0.1, 0.1);
			else
				-- Alliance won
				WorldStateScoreWinnerFrameLeft:SetVertexColor(0.11, 0.26, 0.51);
				WorldStateScoreWinnerFrameRight:SetVertexColor(0.11, 0.26, 0.51);
				WorldStateScoreWinnerFrameText:SetVertexColor(0, 0.68, 0.94);
			end
		end
		WorldStateScoreWinnerFrame:Show();
	else
		WorldStateScoreWinnerFrame:Hide();
		WorldStateScoreFrameLeaveButton:Hide();
		WorldStateScoreFrameQueueButton:Hide();
		WorldStateScoreFrameTimerLabel:Hide();
		WorldStateScoreFrameTimer:Hide();
	end

	-- Update buttons
	local numScores = GetNumBattlefieldScores();

	local scoreButton, columnButtonIcon;
	local name, kills, killingBlows, honorableKills, deaths, honorGained, faction, race, class, classToken, damageDone, healingDone, bgRating, ratingChange, preMatchMMR, mmrChange, talentSpec;
	local teamName, teamRating, newTeamRating, teamMMR;
	local index;
	local columnData;

		-- ScrollFrame update
	local hasScrollBar;
	if ( numScores > MAX_WORLDSTATE_SCORE_BUTTONS ) then
		hasScrollBar = 1;
		WorldStateScoreScrollFrame:Show();
	else
		WorldStateScoreScrollFrame:Hide();
		end
	FauxScrollFrame_Update(WorldStateScoreScrollFrame, numScores, MAX_WORLDSTATE_SCORE_BUTTONS, SCORE_BUTTON_HEIGHT );

	-- Setup Columns
	local text, icon, tooltip, columnButton;
	local numStatColumns = GetNumBattlefieldStats();
	local columnButton, columnButtonText, columnTextButton, columnIcon;
	local lastStatsFrame = "WorldStateScoreFrameHealingDone";
	for i=1, MAX_NUM_STAT_COLUMNS do
		if ( i <= numStatColumns ) then
			text, icon, tooltip = GetBattlefieldStatInfo(i);
			columnButton = _G["WorldStateScoreColumn"..i];
			columnButtonText = _G["WorldStateScoreColumn"..i.."Text"];
			columnButtonText:SetText(text);
			columnButton.icon = icon;
			columnButton.tooltip = tooltip;

			columnTextButton = _G["WorldStateScoreButton1Column"..i.."Text"];

			if ( icon ~= "" ) then
				columnTextButton:SetPoint("CENTER", "WorldStateScoreColumn"..i, "CENTER", 6, WORLDSTATECOREFRAME_BUTTON_TEXT_OFFSET);
			else
				columnTextButton:SetPoint("CENTER", "WorldStateScoreColumn"..i, "CENTER", -1, WORLDSTATECOREFRAME_BUTTON_TEXT_OFFSET);
			end


			if ( i == numStatColumns ) then
				lastStatsFrame = "WorldStateScoreColumn"..i;
			end

			_G["WorldStateScoreColumn"..i]:Show();
		else
			_G["WorldStateScoreColumn"..i]:Hide();
		end
	end

	-- Anchor the next frame to the last column shown
	firstFrameAfterCustomStats:SetPoint("LEFT", lastStatsFrame, "RIGHT", 5, 0);

	-- Last button shown is what the player count anchors to
	local lastButtonShown = "WorldStateScoreButton1";
	local teamDataFailed, coords;
	local scrollOffset = FauxScrollFrame_GetOffset(WorldStateScoreScrollFrame);

	for i=1, MAX_WORLDSTATE_SCORE_BUTTONS do
		-- Need to create an index adjusted by the scrollframe offset
		index = scrollOffset + i;
		scoreButton = _G["WorldStateScoreButton"..i];
		if ( hasScrollBar ) then
			scoreButton:SetWidth(WorldStateScoreFrame.scrollBarButtonWidth);
		else
			scoreButton:SetWidth(WorldStateScoreFrame.buttonWidth);
		end
		if ( index <= numScores ) then
			scoreButton.index = index;
			name, killingBlows, honorableKills, deaths, honorGained, faction, race, class, classToken, damageDone, healingDone, bgRating, ratingChange, preMatchMMR, mmrChange, talentSpec, prestige = GetBattlefieldScore(index);

			if ( classToken ) then
				coords = CLASS_ICON_TCOORDS[classToken];
				scoreButton.class.icon:SetTexture("Interface\\WorldStateFrame\\Icons-Classes");
				scoreButton.class.icon:SetTexCoord(coords[1], coords[2], coords[3], coords[4]);
				scoreButton.class:Show();
			else
				scoreButton.class:Hide();
			end

			if ( prestige > 0 ) then
				scoreButton.prestige.icon:SetTexture(GetPrestigeInfo(prestige) or 0);
				scoreButton.prestige:Show();
			else
				scoreButton.prestige:Hide();
			end

			scoreButton.name.text:SetText(name);
			if ( not race ) then
				race = "";
			end
			if ( not class ) then
				class = "";
			end
			scoreButton.name.name = name;
			scoreButton.name.tooltip = race.." "..class;
			if ( talentSpec ) then
				_G["WorldStateScoreButton"..i.."ClassButton"].tooltip = format(TALENT_SPEC_AND_CLASS, talentSpec, class);
			else
				_G["WorldStateScoreButton"..i.."ClassButton"].tooltip = class;
			end
			scoreButton.killingBlows:SetText(killingBlows);

			-- TODO HERE
			scoreButton.damage:SetText(format_thousand(damageDone));
			scoreButton.healing:SetText(format_thousand(healingDone));
			teamDataFailed = 0;
			teamName, teamRating, newTeamRating, teamMMR = GetBattlefieldTeamInfo(faction);

			if ( not teamRating ) then
				teamDataFailed = 1;
			end

			if ( not newTeamRating ) then
				teamDataFailed = 1;
			end

			if ( isArena ) then
				scoreButton.name.text:SetWidth(350);
				if ( isRegistered ) then
					scoreButton.team:SetText(teamName);
					scoreButton.team:Show();
					if (not isSkirmish) then
						if ( teamDataFailed == 1 ) then
							scoreButton.ratingChange:SetText("-------");
						else
							if ratingChange > 0 then
								scoreButton.ratingChange:SetText(GREEN_FONT_COLOR_CODE..ratingChange..FONT_COLOR_CODE_CLOSE);
							else
								scoreButton.ratingChange:SetText(RED_FONT_COLOR_CODE..ratingChange..FONT_COLOR_CODE_CLOSE);
							end
						end
						scoreButton.ratingChange:Show();
					else
						scoreButton.ratingChange:Hide();
					end
				else
					scoreButton.team:Hide();
					scoreButton.ratingChange:Hide();
				end
				scoreButton.honorableKills:Hide();
				scoreButton.honorGained:Hide();
				scoreButton.deaths:Hide();
				scoreButton.bgRating:Hide();
			else
				scoreButton.name.text:SetWidth(175);
				scoreButton.deaths:SetText(deaths);
				scoreButton.team:Hide();
				scoreButton.deaths:Show();
				if isRatedBG then
					if battlefieldWinner then
						if ratingChange > 0 then
							scoreButton.ratingChange:SetText(GREEN_FONT_COLOR_CODE..ratingChange..FONT_COLOR_CODE_CLOSE);
						else
							scoreButton.ratingChange:SetText(RED_FONT_COLOR_CODE..ratingChange..FONT_COLOR_CODE_CLOSE);
						end
						scoreButton.ratingChange:Show();
					else
						scoreButton.ratingChange:Hide();
					end
					scoreButton.bgRating:SetText(bgRating);
					scoreButton.bgRating:Show();
					scoreButton.honorGained:Hide();
					scoreButton.honorableKills:Hide();
				else
					scoreButton.honorGained:SetText(floor(honorGained));
					scoreButton.honorGained:Show();
					scoreButton.honorableKills:SetText(honorableKills);
					scoreButton.honorableKills:Show();
					scoreButton.ratingChange:Hide();
					scoreButton.bgRating:Hide();
				end
				scoreButton.matchmakingRating:Hide();
			end

			for j=1, MAX_NUM_STAT_COLUMNS do
				columnButtonText = _G["WorldStateScoreButton"..i.."Column"..j.."Text"];
				columnButtonIcon = _G["WorldStateScoreButton"..i.."Column"..j.."Icon"];
				if ( j <= numStatColumns ) then
					-- If there's an icon then move the icon left and format the text with an "x" in front
					columnData = GetBattlefieldStatData(index, j);
					if ( _G["WorldStateScoreColumn"..j].icon ~= "" ) then
						if ( columnData > 0 ) then
							columnButtonText:SetFormattedText(FLAG_COUNT_TEMPLATE, columnData);
							columnButtonIcon:SetTexture(_G["WorldStateScoreColumn"..j].icon..faction);
							columnButtonIcon:Show();
						else
							columnButtonText:SetText("");
							columnButtonIcon:Hide();
						end

					else
						columnButtonText:SetText(columnData);
						columnButtonIcon:Hide();
					end
					columnButtonText:Show();
				else
					columnButtonText:Hide();
					columnButtonIcon:Hide();
				end
			end
			if ( faction ) then
				if ( faction == 0 ) then
					if ( isArena ) then
						-- Green Team
						scoreButton.factionLeft:SetVertexColor(0.19, 0.57, 0.11);
						scoreButton.factionRight:SetVertexColor(0.19, 0.57, 0.11);
						scoreButton.name.text:SetVertexColor(0.1, 1.0, 0.1);
					else
						-- Horde
						scoreButton.factionLeft:SetVertexColor(0.52, 0.075, 0.18);
						scoreButton.factionRight:SetVertexColor(0.5, 0.075, 0.18);
						scoreButton.name.text:SetVertexColor(1.0, 0.1, 0.1);
					end
				else
					if ( isArena ) then
						-- Gold Team
						scoreButton.factionLeft:SetVertexColor(0.85, 0.71, 0.26);
						scoreButton.factionRight:SetVertexColor(0.85, 0.71, 0.26);
						scoreButton.name.text:SetVertexColor(1, 0.82, 0);
					else
						-- Alliance
						scoreButton.factionLeft:SetVertexColor(0.11, 0.26, 0.51);
						scoreButton.factionRight:SetVertexColor(0.11, 0.26, 0.51);
						scoreButton.name.text:SetVertexColor(0, 0.68, 0.94);
					end
				end
				if ( ( not isArena ) and ( name == UnitName( "player" ) ) ) then
					scoreButton.factionLeft:SetVertexColor(  1.0, 0.82, 0 );
					scoreButton.factionRight:SetVertexColor( 1.0, 0.82, 0 );

					scoreButton.name.text:SetVertexColor(    1.0, 0.82, 0 );
				end

				if ( ( isArena ) and ( name == UnitName( "player" ) ) ) then
					scoreButton.factionLeft:SetVertexColor(  0, 255, 255 );
					scoreButton.factionRight:SetVertexColor( 0, 255, 255 );
					scoreButton.name.text:SetVertexColor(    0, 255, 255 );
				end

				scoreButton.factionLeft:Show();
				scoreButton.factionRight:Show();
			else
				scoreButton.factionLeft:Hide();
				scoreButton.factionRight:Hide();
			end
			lastButtonShown = scoreButton:GetName();
			scoreButton:Show();
		else
			scoreButton:Hide();
		end
	end

	-- Show average matchmaking rating at the bottom
	if isRatedBG or ((isArena and isRegistered) and not isSkirmish) then
		local _, ourAverageMMR, theirAverageMMR;
		local myFaction = GetBattlefieldArenaFaction();
		_, _, _, ourAverageMMR = GetBattlefieldTeamInfo(myFaction);
		_, _, _, theirAverageMMR = GetBattlefieldTeamInfo((myFaction+1)%2);
		WorldStateScoreFrame.teamAverageRating:Show();
		WorldStateScoreFrame.enemyTeamAverageRating:Show();
		WorldStateScoreFrame.teamAverageRating:SetFormattedText(BATTLEGROUND_YOUR_AVERAGE_RATING, ourAverageMMR);
		WorldStateScoreFrame.enemyTeamAverageRating:SetFormattedText(BATTLEGROUND_ENEMY_AVERAGE_RATING, theirAverageMMR);
	else
		WorldStateScoreFrame.teamAverageRating:Hide();
		WorldStateScoreFrame.enemyTeamAverageRating:Hide();
	end

	-- Count number of players on each side
	local _, _, _, _, numHorde = GetBattlefieldTeamInfo(0);
	local _, _, _, _, numAlliance = GetBattlefieldTeamInfo(1);

	-- Set count text and anchor team count to last button shown
	WorldStateScorePlayerCount:Show();
	if ( numHorde > 0 and numAlliance > 0 ) then
		WorldStateScorePlayerCount:SetText(format(PLAYER_COUNT_ALLIANCE, numAlliance).." / "..format(PLAYER_COUNT_HORDE, numHorde));
	elseif ( numAlliance > 0 ) then
		WorldStateScorePlayerCount:SetFormattedText(PLAYER_COUNT_ALLIANCE, numAlliance);
	elseif ( numHorde > 0 ) then
		WorldStateScorePlayerCount:SetFormattedText(PLAYER_COUNT_HORDE, numHorde);
	else
		WorldStateScorePlayerCount:Hide();
	end
	if ( isArena ) then
		WorldStateScorePlayerCount:Hide();
	end


	if GetBattlefieldInstanceRunTime() > 60000 then
		WorldStateScoreBattlegroundRunTime:Show();
		WorldStateScoreBattlegroundRunTime:SetText(TIME_ELAPSED.." "..SecondsToTime(GetBattlefieldInstanceRunTime()/1000, true));
	else
		WorldStateScoreBattlegroundRunTime:Hide();
	end
end