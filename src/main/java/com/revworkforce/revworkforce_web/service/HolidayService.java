package com.revworkforce.revworkforce_web.service;

import com.revworkforce.revworkforce_web.dao.HolidayDao;
import com.revworkforce.revworkforce_web.model.Holiday;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class HolidayService {

    private final HolidayDao holidayDao;

    public List<Holiday> findAll() {
        return holidayDao.findAll();
    }

    public Holiday save(Holiday holiday) {
        return holidayDao.save(holiday);
    }

    public void delete(Long id) {
        holidayDao.delete(id);
    }
}
