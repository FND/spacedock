// Generated code, any edits will be eventually lost.
package com.funnyhatsoftware.spacedock.data;

import java.util.ArrayList;
import java.util.Map;

public class ShipClassDetailsBase extends Base {
    String mExternalId;
    public String getExternalId() { return mExternalId; }
    public ShipClassDetailsBase setExternalId(String v) { mExternalId = v; return this;}
    String mFrontArc;
    public String getFrontArc() { return mFrontArc; }
    public ShipClassDetailsBase setFrontArc(String v) { mFrontArc = v; return this;}
    String mName;
    public String getName() { return mName; }
    public ShipClassDetailsBase setName(String v) { mName = v; return this;}
    String mRearArc;
    public String getRearArc() { return mRearArc; }
    public ShipClassDetailsBase setRearArc(String v) { mRearArc = v; return this;}
    ArrayList<Maneuver> mManeuvers = new ArrayList<Maneuver>();
    @SuppressWarnings("unchecked")
    public ArrayList<Maneuver> getManeuvers() { return (ArrayList<Maneuver>)mManeuvers.clone(); }
    @SuppressWarnings("unchecked")
    public ShipClassDetailsBase setManeuvers(ArrayList<Maneuver> v) { mManeuvers = (ArrayList<Maneuver>)v.clone(); return this;}
    ArrayList<Ship> mShips = new ArrayList<Ship>();
    @SuppressWarnings("unchecked")
    public ArrayList<Ship> getShips() { return (ArrayList<Ship>)mShips.clone(); }
    @SuppressWarnings("unchecked")
    public ShipClassDetailsBase setShips(ArrayList<Ship> v) { mShips = (ArrayList<Ship>)v.clone(); return this;}

    public void update(Map<String,Object> data) {
        mExternalId = DataUtils.stringValue((String)data.get("Id"), "");
        mFrontArc = DataUtils.stringValue((String)data.get("FrontArc"), "");
        mName = DataUtils.stringValue((String)data.get("Name"), "");
        mRearArc = DataUtils.stringValue((String)data.get("RearArc"), "");
    }

}
