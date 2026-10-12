package com.campusgreen.model;

public class Slot {
    private int slotId;
    private String vehicleType;
    private String route;
    private String slotTime;
    private int capacity;
    private int bookedCount;
    private int heldCount; // seats currently on a live 2-minute hold

    public int getSlotId() { return slotId; }
    public void setSlotId(int slotId) { this.slotId = slotId; }

    public String getVehicleType() { return vehicleType; }
    public void setVehicleType(String vehicleType) { this.vehicleType = vehicleType; }

    public String getRoute() { return route; }
    public void setRoute(String route) { this.route = route; }

    public String getSlotTime() { return slotTime; }
    public void setSlotTime(String slotTime) { this.slotTime = slotTime; }

    public int getCapacity() { return capacity; }
    public void setCapacity(int capacity) { this.capacity = capacity; }

    public int getBookedCount() { return bookedCount; }
    public void setBookedCount(int bookedCount) { this.bookedCount = bookedCount; }

    public int getHeldCount() { return heldCount; }
    public void setHeldCount(int heldCount) { this.heldCount = heldCount; }

    // Held seats count as taken, so nobody else can grab them while a hold is live
    public int getSeatsLeft() { return capacity - bookedCount - heldCount; }
    public boolean isFull() { return getSeatsLeft() <= 0; }
}
