package com.funnyhatsoftware.spacedock;

import java.util.ArrayList;

class Resource extends SetItem {
	String ability;
	int cost;
	String externalId;
	String special;
	String title;
	String type;
	boolean unique;
	ArrayList<Squad> squad = new ArrayList<Squad>();
}
