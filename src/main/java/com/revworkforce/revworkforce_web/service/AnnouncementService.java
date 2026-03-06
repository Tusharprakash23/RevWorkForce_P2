package com.revworkforce.revworkforce_web.service;

import com.revworkforce.revworkforce_web.dao.AnnouncementDao;
import com.revworkforce.revworkforce_web.model.Announcement;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class AnnouncementService {

    private final AnnouncementDao announcementDao;

    public List<Announcement> findAll() {
        return announcementDao.findAll();
    }

    public Announcement save(Announcement announcement) {
        return announcementDao.save(announcement);
    }

    public void update(Long id, String title, String description) {
        announcementDao.update(id, title, description);
    }

    public void delete(Long id) {
        announcementDao.delete(id);
    }
}
